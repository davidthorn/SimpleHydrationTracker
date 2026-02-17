//
//  NotificationPermissionsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI
import SimpleFramework
import UIKit

internal struct NotificationPermissionsView: View {
    @StateObject private var viewModel: NotificationPermissionsViewModel

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = NotificationPermissionsViewModel(reminderService: serviceContainer.reminderService)
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SimpleHeroCard(
                        title: "Notification Permissions",
                        message: "Control how hydration reminders are allowed to notify you.",
                        systemImage: "lock.shield",
                        tint: AppTheme.warning
                    )

                    statusCard
                    actionsCard

                    if let errorMessage = viewModel.errorMessage {
                        SimpleFormErrorCard(message: errorMessage, tint: AppTheme.error)
                        SimpleActionButton(
                            title: "Dismiss",
                            systemImage: "xmark",
                            tint: AppTheme.muted,
                            style: .bordered,
                            isEnabled: true
                        ) {
                            viewModel.clearError()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Permissions")
        .tint(AppTheme.accent)
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

    @ViewBuilder
    private var statusCard: some View {
        switch viewModel.status {
        case .authorized:
            SimpleStatusCard(
                title: "Authorized",
                message: "Notifications are enabled for this app.",
                systemImage: "checkmark.seal.fill",
                tint: AppTheme.success
            )
        case .provisional:
            SimpleStatusCard(
                title: "Provisional Access",
                message: "Notifications can be delivered quietly.",
                systemImage: "bell.badge",
                tint: AppTheme.warning
            )
        case .notDetermined:
            SimpleStatusCard(
                title: "Not Requested",
                message: "Request permission to enable reminders.",
                systemImage: "questionmark.circle",
                tint: AppTheme.warning
            )
        case .denied:
            SimpleStatusCard(
                title: "Denied",
                message: "Open iOS Settings to enable notifications.",
                systemImage: "xmark.octagon.fill",
                tint: AppTheme.error
            )
        }
    }

    @ViewBuilder
    private var actionsCard: some View {
        if viewModel.status == .notDetermined {
            SimpleActionButton(
                title: "Request Permission",
                systemImage: "bell.badge.fill",
                tint: AppTheme.accent,
                style: .filled,
                isEnabled: viewModel.isLoading == false
            ) {
                Task {
                    guard Task.isCancelled == false else {
                        return
                    }
                    await viewModel.requestPermission()
                }
            }
        }

        if viewModel.status == .denied {
            SimpleActionButton(
                title: "Open Settings",
                systemImage: "gearshape.fill",
                tint: AppTheme.warning,
                style: .filled,
                isEnabled: true
            ) {
                guard let url = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                UIApplication.shared.open(url)
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
