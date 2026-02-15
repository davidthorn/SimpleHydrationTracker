//
//  SettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct SettingsView: View {
    internal var body: some View {
        List {
            NavigationLink(value: SettingsRoute.goalSettings) {
                Text("Goal Settings")
            }
            NavigationLink(value: SettingsRoute.reminderSettings) {
                Text("Reminder Settings")
            }
            NavigationLink(value: SettingsRoute.notificationPermissions) {
                Text("Notification Permissions")
            }
            NavigationLink(value: SettingsRoute.unitsSettings) {
                Text("Units Settings")
            }
            NavigationLink(value: SettingsRoute.dataManagement) {
                Text("Data Management")
            }
        }
        .navigationTitle("Settings")
    }
}

#if DEBUG
    #Preview {
        SettingsView()
    }
#endif
