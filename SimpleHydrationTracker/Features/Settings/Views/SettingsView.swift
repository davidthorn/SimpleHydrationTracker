//
//  SettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = SettingsViewModel(unitsPreferenceService: serviceContainer.unitsPreferenceService)
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        List {
            Section("Hydration") {
                NavigationLink(value: SettingsRoute.goalSettings) {
                    LabeledContent("Goal", value: "Daily Target")
                }
            }

            Section("Notifications") {
                NavigationLink(value: SettingsRoute.reminderSettings) {
                    LabeledContent("Reminders", value: "Schedule")
                }
                NavigationLink(value: SettingsRoute.notificationPermissions) {
                    LabeledContent("Permissions", value: "Access")
                }
            }

            Section("Preferences") {
                NavigationLink(value: SettingsRoute.unitsSettings) {
                    LabeledContent("Units", value: viewModel.selectedUnit.settingsValueLabel)
                }
            }

            Section("Data") {
                NavigationLink(value: SettingsRoute.dataManagement) {
                    LabeledContent("Data Management", value: "Export & Delete")
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section("Error") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(errorMessage)
                            .foregroundStyle(AppTheme.error)
                            .font(.footnote)
                        Button("Dismiss", role: .cancel) {
                            viewModel.clearError()
                        }
                    }
                }
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
