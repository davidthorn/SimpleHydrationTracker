//
//  SettingsScene.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct SettingsScene: View {
    private let serviceContainer: ServiceContainerProtocol

    internal init(serviceContainer: ServiceContainerProtocol) {
        self.serviceContainer = serviceContainer
    }

    internal var body: some View {
        NavigationStack {
            SettingsView(serviceContainer: serviceContainer)
                .navigationDestination(for: SettingsRoute.self) { route in
                    switch route {
                    case .goalSettings:
                        GoalSetupView(serviceContainer: serviceContainer)
                    case .reminderSettings:
                        ReminderSettingsView(serviceContainer: serviceContainer)
                    case .notificationPermissions:
                        NotificationPermissionsView(serviceContainer: serviceContainer)
                    case .unitsSettings:
                        UnitsSettingsView(serviceContainer: serviceContainer)
                    case .sipSizeSettings:
                        SipSizeSettingsView(serviceContainer: serviceContainer)
                    case .healthKitSettings:
                        HealthKitSettingsView(serviceContainer: serviceContainer)
                    case .dataManagement:
                        DataManagementView(serviceContainer: serviceContainer)
                    }
                }
        }
    }
}

#if DEBUG
    #Preview {
        SettingsScene(serviceContainer: PreviewServiceContainer())
    }
#endif
