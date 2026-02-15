//
//  NotificationPermissionsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI
import UIKit

internal struct NotificationPermissionsView: View {
    @StateObject private var viewModel: NotificationPermissionsViewModel

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = NotificationPermissionsViewModel(reminderService: serviceContainer.reminderService)
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        Form {
            Section {
                SettingsHeroCardComponent(
                    title: "Notification Permissions",
                    message: "Control how hydration reminders are allowed to notify you.",
                    systemImage: "lock.shield",
                    tint: AppTheme.warning
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Status") {
                switch viewModel.status {
                case .authorized:
                    SettingsStatusCardComponent(
                        title: "Authorized",
                        message: "Notifications are enabled for this app.",
                        systemImage: "checkmark.seal.fill",
                        tint: AppTheme.success
                    )
                case .provisional:
                    SettingsStatusCardComponent(
                        title: "Provisional Access",
                        message: "Notifications can be delivered quietly.",
                        systemImage: "bell.badge",
                        tint: AppTheme.warning
                    )
                case .notDetermined:
                    SettingsStatusCardComponent(
                        title: "Not Requested",
                        message: "Request permission to enable reminders.",
                        systemImage: "questionmark.circle",
                        tint: AppTheme.warning
                    )
                case .denied:
                    SettingsStatusCardComponent(
                        title: "Denied",
                        message: "Open iOS Settings to enable notifications.",
                        systemImage: "xmark.octagon.fill",
                        tint: AppTheme.error
                    )
                }
            }

            Section("Actions") {
                if viewModel.status == .notDetermined {
                    Button("Request Permission") {
                        Task {
                            guard Task.isCancelled == false else {
                                return
                            }
                            await viewModel.requestPermission()
                        }
                    }
                }

                if viewModel.status == .denied {
                    Button("Open Settings") {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        UIApplication.shared.open(url)
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    SettingsStatusCardComponent(
                        title: "Permission Error",
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle.fill",
                        tint: AppTheme.error
                    )
                    Button("Dismiss", role: .cancel) {
                        viewModel.clearError()
                    }
                }
            }
        }
        .navigationTitle("Permissions")
        .scrollContentBackground(.hidden)
        .background(AppTheme.pageGradient)
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.start()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Checking permission...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            NotificationPermissionsView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
