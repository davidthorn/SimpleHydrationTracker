//
//  ReminderSettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct ReminderSettingsView: View {
    internal var body: some View {
        Text("Reminder Settings")
            .navigationTitle("Reminders")
    }
}

#if DEBUG
    #Preview {
        ReminderSettingsView()
    }
#endif
