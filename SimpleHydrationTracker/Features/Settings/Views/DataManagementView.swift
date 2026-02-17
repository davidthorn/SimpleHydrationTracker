//
//  DataManagementView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI
import SimpleFramework

internal struct DataManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DataManagementViewModel
    @State private var showDeleteConfirmation: Bool

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = DataManagementViewModel(
            hydrationService: serviceContainer.hydrationService,
            goalService: serviceContainer.goalService,
            healthKitHydrationService: serviceContainer.healthKitHydrationService,
            hydrationEntrySyncMetadataService: serviceContainer.hydrationEntrySyncMetadataService
        )
        _viewModel = StateObject(wrappedValue: vm)
        _showDeleteConfirmation = State(initialValue: false)
    }

    internal var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SimpleHeroCard(
                        title: "Data Management",
                        message: "Export records for review or delete all hydration and sync data when needed.",
                        systemImage: "tray.full",
                        tint: AppTheme.error
                    )

                    sectionTitle("Export")
                    SimpleInfoActionCard(
                        title: "Prepare Export",
                        subtitle: "Create export output for your hydration records.",
                        systemImage: "square.and.arrow.up",
                        tint: AppTheme.success,
                        actionTitle: "Prepare Export",
                        actionSystemImage: "square.and.arrow.up",
                        actionTint: AppTheme.success,
                        isActionEnabled: viewModel.isExporting == false && viewModel.isDeletingAll == false,
                        action: {
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                await viewModel.exportData()
                            }
                        }
                    )

                    if let exportMessage = viewModel.exportResultMessage {
                        SimpleFeedbackCard(
                            message: exportMessage,
                            tint: AppTheme.success
                        )
                    }

                    sectionTitle("Delete")
                    SimpleInfoActionCard(
                        title: "Delete All Data",
                        subtitle: "Permanently remove hydration entries, goals, and sync data.",
                        systemImage: "trash.fill",
                        tint: AppTheme.error,
                        actionTitle: "Delete All Data",
                        actionSystemImage: "trash.fill",
                        actionTint: AppTheme.error,
                        isActionEnabled: viewModel.isExporting == false && viewModel.isDeletingAll == false,
                        action: {
                            showDeleteConfirmation = true
                        }
                    )

                    if let errorMessage = viewModel.errorMessage {
                        SimpleFormErrorCard(message: errorMessage, tint: AppTheme.error)

                        SimpleInfoActionCard(
                            title: "Error",
                            subtitle: "Dismiss to continue managing data actions.",
                            systemImage: "xmark.octagon.fill",
                            tint: AppTheme.muted,
                            actionTitle: "Dismiss",
                            actionSystemImage: "xmark",
                            actionTint: AppTheme.muted,
                            action: {
                                viewModel.clearMessages()
                            }
                        )
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Data")
        .tint(AppTheme.accent)
        .overlay {
            if showDeleteConfirmation {
                ZStack {
                    Color.black.opacity(0.16)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if viewModel.isDeletingAll {
                                return
                            }
                            showDeleteConfirmation = false
                        }

                    SimpleDestructiveConfirmationCard(
                        title: "Delete all hydration data?",
                        message: "This permanently removes entries, goals, and sync metadata in this app.",
                        confirmTitle: "Delete All Data",
                        tint: AppTheme.error,
                        isDisabled: viewModel.isDeletingAll,
                        onCancel: {
                            showDeleteConfirmation = false
                        },
                        onConfirm: {
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                await viewModel.deleteAllData()
                                guard Task.isCancelled == false else {
                                    return
                                }
                                dismiss()
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showDeleteConfirmation)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .foregroundStyle(AppTheme.muted)
    }

}

#if DEBUG
    #Preview {
        NavigationStack {
            DataManagementView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
