//
//  SettingsScene.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct SettingsScene: View {
    internal var body: some View {
        NavigationStack {
            SettingsView()
                .navigationDestination(for: SettingsRoute.self) { route in
                    switch route {
                    case .goalSettings:
                        GoalSettingsView()
                    case .reminderSettings:
                        ReminderSettingsView()
                    case .notificationPermissions:
                        NotificationPermissionsView()
                    case .unitsSettings:
                        UnitsSettingsView()
                    case .dataManagement:
                        DataManagementView()
                    }
                }
        }
    }
}

#if DEBUG
    #Preview {
        SettingsScene()
    }
#endif
