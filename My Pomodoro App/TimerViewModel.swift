//
//  TimerViewModel.swift
//  My Pomodoro App
//
//  Created by  Trey Leong on 17/4/25.
//

// TimerViewModel.swift
import SwiftUI // Needed for @Published etc.
import UserNotifications // Needed for Notifications

// --- Pomodoro States ---
enum PomodoroState: String, CaseIterable {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
}

// --- ViewModel ---
class TimerViewModel: ObservableObject {

    // MARK: - Published Properties (UI Updates)
    @Published var timeRemaining: Int
    @Published var currentState: PomodoroState = .work
    @Published var isActive: Bool = false
    @Published var pomodorosCompletedThisSession: Int = 0

    // MARK: - Timer Configuration (Could be made configurable later)
    private let workDuration: Int = 25 * 60 // 25 minutes
    private let shortBreakDuration: Int = 5 * 60  // 5 minutes
    private let longBreakDuration: Int = 15 * 60 // 15 minutes
    private let pomodorosBeforeLongBreak: Int = 4

    // MARK: - Private Timer Properties
    private var timer: Timer?
    private var totalDurationForCurrentState: Int // To calculate progress

    // MARK: - Computed Properties
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var currentStateDisplay: String {
        // Provide a slightly more descriptive state name if needed
        switch currentState {
            case .work: return "Focus" // Example customization
            default: return currentState.rawValue // Use enum raw value
        }
    }

    var progress: Double {
        guard totalDurationForCurrentState > 0 else { return 0 }
        // Calculate progress: 1.0 means full, 0.0 means empty
        return 1.0 - (Double(timeRemaining) / Double(totalDurationForCurrentState))
    }

    // MARK: - Initialization
    init() {
        // Start in work state
        self.timeRemaining = workDuration
        self.totalDurationForCurrentState = workDuration
    }

    // MARK: - Timer Control Methods
    func startTimer() {
        guard !isActive else { return } // Don't start if already active

        // Ensure totalDuration is correct before starting
        self.totalDurationForCurrentState = duration(for: currentState)

        isActive = true
        // Schedule timer that fires every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timerCompleted()
            }
        }
        // Run the timer on the main run loop for UI updates
        RunLoop.main.add(timer!, forMode: .common)
    }

    func pauseTimer() {
        isActive = false
        timer?.invalidate() // Stop the timer
        timer = nil
    }

    func resetTimer() {
        pauseTimer()
        // Reset to the duration of the *current* state
        timeRemaining = duration(for: currentState)
        totalDurationForCurrentState = timeRemaining // Reset progress
    }

    func skipTimer() {
         pauseTimer()
         timerCompleted() // Directly trigger the completion logic
    }

    // MARK: - State Transition Logic
    private func timerCompleted() {
        pauseTimer() // Ensure timer is stopped
        sendNotification(completedState: currentState) // Notify based on finished state

        // Determine the next state
        switch currentState {
        case .work:
            pomodorosCompletedThisSession += 1
            if pomodorosCompletedThisSession % pomodorosBeforeLongBreak == 0 {
                currentState = .longBreak
            } else {
                currentState = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentState = .work
        }

        // Set up for the next state
        timeRemaining = duration(for: currentState)
        totalDurationForCurrentState = timeRemaining

        // Optional: Automatically start the next timer? Comment out if manual start is preferred.
         // startTimer()
    }

    // MARK: - Helper Methods
    private func duration(for state: PomodoroState) -> Int {
        switch state {
        case .work: return workDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }

    // MARK: - Notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    private func sendNotification(completedState: PomodoroState) {
        let content = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default // Basic sound

        switch completedState {
        case .work:
            content.title = "Work Session Over!"
            content.body = pomodorosCompletedThisSession % pomodorosBeforeLongBreak == 0
                ? "Time for a long break (\(longBreakDuration / 60) min)."
                : "Time for a short break (\(shortBreakDuration / 60) min)."
        case .shortBreak:
            content.title = "Break Over!"
            content.body = "Time to get back to focus (\(workDuration / 60) min)."
        case .longBreak:
            content.title = "Long Break Over!"
            content.body = "Ready for the next focus session? (\(workDuration / 60) min)."
        }

        // Show notification immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
             if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
