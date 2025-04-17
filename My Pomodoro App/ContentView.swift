//
//  ContentView.swift
//  My Pomodoro App
//
//  Created by  Trey Leong on 17/4/25.
//

import SwiftUI
import UserNotifications // Needed for permission request

struct ContentView: View {
    // Create and manage the ViewModel instance
    @StateObject private var viewModel = TimerViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Spacer() // Push content towards center/top

            // Current State Display
            Text(viewModel.currentStateDisplay)
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)

            // Timer Display
            Text(viewModel.timeString)
                .font(.system(size: 90, weight: .thin, design: .monospaced))
                .foregroundColor(.primary) // Adapts to light/dark
                .padding(.bottom, 10)

            // Progress View
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 200)
                .padding(.bottom, 30)


            // Control Buttons
            HStack(spacing: 40) {
                // Start/Pause Button
                Button {
                    viewModel.isActive ? viewModel.pauseTimer() : viewModel.startTimer()
                } label: {
                    Image(systemName: viewModel.isActive ? "pause.fill" : "play.fill")
                        .font(.system(size: 35))
                        .frame(width: 50, height: 50) // Ensure consistent button size
                }
                .buttonStyle(.plain) // Use plain style for icon buttons on macOS
                .tint(viewModel.isActive ? .orange : .green) // Add color indication

                // Reset Button
                Button {
                    viewModel.resetTimer()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 30))
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(.plain)
                .tint(.gray)
                .disabled(viewModel.isActive) // Disable reset while timer is running

                // Skip Button
                Button {
                    viewModel.skipTimer()
                } label: {
                     Image(systemName: "forward.end.fill")
                        .font(.system(size: 30))
                        .frame(width: 50, height: 50)
                }
                .buttonStyle(.plain)
                .tint(.blue)

            } // End HStack

            Spacer() // Push content towards center/bottom
        }
        // Apply padding around the entire VStack content
        .padding(30)
        // Set a dark color scheme preference (optional, remove to follow system)
        // .preferredColorScheme(.dark)
        .background(Color(NSColor.windowBackgroundColor)) // Use standard window background
        .onAppear {
            // Request notification permission when the view appears
            viewModel.requestNotificationPermission()
        }
        // Optional: Add subtle animation when timer state changes
        .animation(.easeInOut, value: viewModel.isActive)
        .animation(.easeInOut, value: viewModel.currentState)

    } // End body
}

// SwiftUI Preview (for Xcode Canvas)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            // You can force dark mode for the preview like this:
           // .preferredColorScheme(.dark)
    }
}

