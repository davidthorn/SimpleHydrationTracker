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
                    actionCard {
                        SimpleActionButton(
                            title: "Prepare Export",
                            systemImage: "square.and.arrow.up",
                            tint: AppTheme.success,
                            style: .filled,
                            isEnabled: viewModel.isExporting == false && viewModel.isDeletingAll == false
                        ) {
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                await viewModel.exportData()
                            }
                        }
                    }

                    if let exportMessage = viewModel.exportResultMessage {
                        SimpleStatusCard(
                            title: "Export Ready",
                            message: exportMessage,
                            systemImage: "square.and.arrow.up",
                            tint: AppTheme.success
                        )
                    }

                    sectionTitle("Delete")
                    actionCard {
                        SimpleActionButton(
                            title: "Delete All Data",
                            systemImage: "trash.fill",
                            tint: AppTheme.error,
                            style: .filled,
                            isEnabled: viewModel.isExporting == false && viewModel.isDeletingAll == false
                        ) {
                            showDeleteConfirmation = true
                        }
                    }

                    if let errorMessage = viewModel.errorMessage {
                        SimpleFormErrorCard(message: errorMessage, tint: AppTheme.error)

                        actionCard {
                            SimpleActionButton(
                                title: "Dismiss",
                                systemImage: "xmark",
                                tint: AppTheme.muted,
                                style: .bordered,
                                isEnabled: true
                            ) {
                                viewModel.clearMessages()
                            }
                        }
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

    private func actionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(14)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(AppTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.muted.opacity(0.2), lineWidth: 1)
            )
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            DataManagementView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
