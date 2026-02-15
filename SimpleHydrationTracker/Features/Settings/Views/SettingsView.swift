//
//  SettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Models
import SwiftUI

internal struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = SettingsViewModel(
            unitsPreferenceService: serviceContainer.unitsPreferenceService,
            sipSizePreferenceService: serviceContainer.sipSizePreferenceService
        )
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SettingsHeroCardComponent(
                        title: "Personalize Hydration",
                        message: "Set daily goals, reminders, units, and data controls in one place.",
                        systemImage: "slider.horizontal.3",
                        tint: AppTheme.accent
                    )

                    SettingsRouteSectionComponent(
                        title: "Hydration",
                        rows: [
                            SettingsRow(
                                route: .goalSettings,
                                title: "Goal",
                                subtitle: "Daily target",
                                systemImage: "target",
                                tint: AppTheme.success
                            )
                        ]
                    )

                    SettingsRouteSectionComponent(
                        title: "Notifications",
                        rows: [
                            SettingsRow(
                                route: .reminderSettings,
                                title: "Reminders",
                                subtitle: "Schedule cadence",
                                systemImage: "bell.badge",
                                tint: AppTheme.accent
                            ),
                            SettingsRow(
                                route: .notificationPermissions,
                                title: "Permissions",
                                subtitle: "Access status",
                                systemImage: "lock.shield",
                                tint: AppTheme.warning
                            )
                        ]
                    )

                    SettingsRouteSectionComponent(
                        title: "Preferences",
                        rows: [
                            SettingsRow(
                                route: .unitsSettings,
                                title: "Units",
                                subtitle: viewModel.selectedUnit.settingsValueLabel,
                                systemImage: "ruler",
                                tint: AppTheme.accent
                            ),
                            SettingsRow(
                                route: .sipSizeSettings,
                                title: "Sip Size",
                                subtitle: viewModel.selectedUnit.format(milliliters: viewModel.sipSize.milliliters),
                                systemImage: "mouth",
                                tint: AppTheme.success
                            )
                        ]
                    )

                    SettingsRouteSectionComponent(
                        title: "Data",
                        rows: [
                            SettingsRow(
                                route: .dataManagement,
                                title: "Data Management",
                                subtitle: "Export and clear",
                                systemImage: "tray.full",
                                tint: AppTheme.error
                            )
                        ]
                    )

                    if let errorMessage = viewModel.errorMessage {
                        SettingsStatusCardComponent(
                            title: "Settings Error",
                            message: errorMessage,
                            systemImage: "exclamationmark.triangle.fill",
                            tint: AppTheme.error
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading settings...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .navigationTitle("Settings")
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.start()
        }
        .alert("Settings Error", isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if isPresented == false {
                    viewModel.clearError()
                }
            }
        )
    }
}

#if DEBUG
    #Preview {
        SettingsView(serviceContainer: PreviewServiceContainer())
    }
#endif
