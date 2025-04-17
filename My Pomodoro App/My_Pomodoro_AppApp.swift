//
//  My_Pomodoro_AppApp.swift
//  My Pomodoro App
//
//  Created by  Trey Leong on 17/4/25.
//

import SwiftUI

@main
struct SleekPomodoroApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Set a default window size
                .frame(minWidth: 350, idealWidth: 350, maxWidth: 400,
                       minHeight: 400, idealHeight: 400, maxHeight: 500)
        }
        // Make the window non-resizable for a utility feel (optional)
        // .windowResizability(.contentSize)

        // Remove the standard File/Edit menus for a cleaner look (optional)
        .commandsRemoved()
    }
}

