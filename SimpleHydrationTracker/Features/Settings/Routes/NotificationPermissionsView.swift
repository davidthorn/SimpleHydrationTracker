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
            Section("Status") {
                switch viewModel.status {
                case .authorized:
                    Text("Notifications are authorized.")
                        .foregroundStyle(.secondary)
                case .provisional:
                    Text("Notifications are provisionally authorized.")
                        .foregroundStyle(.secondary)
                case .notDetermined:
                    Text("Notification permission has not been requested.")
                        .foregroundStyle(.secondary)
                case .denied:
                    Text("Notifications are denied for this app.")
                        .foregroundStyle(AppTheme.error)
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
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(AppTheme.error)
                    Button("Dismiss", role: .cancel) {
                        viewModel.clearError()
                    }
                }
            }
        }
        .navigationTitle("Permissions")
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
