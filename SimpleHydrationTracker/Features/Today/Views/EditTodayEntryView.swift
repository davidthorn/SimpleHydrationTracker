//
//  EditTodayEntryView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI
import SimpleFramework

internal struct EditTodayEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditTodayEntryViewModel
    @State private var showDeleteConfirmation: Bool
    @State private var isSaving: Bool
    @State private var isDeleting: Bool

    internal let entryID: HydrationEntryIdentifier

    internal init(entryID: HydrationEntryIdentifier, serviceContainer: ServiceContainerProtocol) {
        self.entryID = entryID
        let vm = EditTodayEntryViewModel(
            entryID: entryID,
            hydrationService: serviceContainer.hydrationService,
            unitsPreferenceService: serviceContainer.unitsPreferenceService,
            healthKitHydrationService: serviceContainer.healthKitHydrationService,
            hydrationEntrySyncMetadataService: serviceContainer.hydrationEntrySyncMetadataService
        )
        _viewModel = StateObject(wrappedValue: vm)
        _showDeleteConfirmation = State(initialValue: false)
        _isSaving = State(initialValue: false)
        _isDeleting = State(initialValue: false)
    }

    internal var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SimpleHeroCard(
                        title: "Edit Entry",
                        message: "Adjust amount or time, then save your updated log.",
                        systemImage: "pencil.circle.fill",
                        tint: AppTheme.warning
                    )

                    amountCard
                    consumedAtCard

                    if let errorMessage = viewModel.errorMessage {
                        SimpleFormErrorCard(message: errorMessage, tint: AppTheme.error)
                    }

                    if viewModel.hasPersistedEntry {
                        healthKitSyncCard
                    }

                    SimpleFormActionButtons(
                        showSave: viewModel.canSave,
                        showReset: viewModel.canReset,
                        showDelete: viewModel.canDelete,
                        saveTitle: "Save Entry",
                        deleteTitle: "Delete Entry",
                        onSave: {
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }

                                isSaving = true
                                defer { isSaving = false }

                                do {
                                    try await viewModel.saveChanges()
                                } catch {
                                    guard Task.isCancelled == false else {
                                        return
                                    }
                                }
                            }
                        },
                        onReset: {
                            viewModel.resetChanges()
                        },
                        onDelete: {
                            showDeleteConfirmation = true
                        }
                    )
                    .opacity((isSaving || isDeleting || viewModel.isLoading) ? 0.6 : 1)
                    .allowsHitTesting(isSaving == false && isDeleting == false && viewModel.isLoading == false)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Edit Entry")
        .tint(AppTheme.accent)
        .overlay {
            if showDeleteConfirmation {
                ZStack {
                    Color.black.opacity(0.16)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if isDeleting {
                                return
                            }
                            showDeleteConfirmation = false
                        }

                    SimpleDestructiveConfirmationCard(
                        title: "Delete this entry?",
                        message: "This entry will be permanently removed from your hydration history.",
                        confirmTitle: "Delete Entry",
                        tint: AppTheme.error,
                        isDisabled: isDeleting,
                        onCancel: {
                            showDeleteConfirmation = false
                        },
                        onConfirm: {
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }

                                isDeleting = true
                                defer { isDeleting = false }

                                do {
                                    try await viewModel.deleteEntry()
                                    guard Task.isCancelled == false else {
                                        return
                                    }
                                    dismiss()
                                } catch {
                                    guard Task.isCancelled == false else {
                                        return
                                    }
                                    showDeleteConfirmation = false
                                }
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.loadIfNeeded()
        }
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.refreshSyncStatus()
        }
        .animation(.easeInOut(duration: 0.2), value: showDeleteConfirmation)
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading entry...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            fieldTitle("Amount")
            TextField(viewModel.selectedUnit.settingsValueLabel, text: $viewModel.amountText)
                .keyboardType(viewModel.selectedUnit == .milliliters ? .numberPad : .decimalPad)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(inputBackground)
                .disabled(isSaving || isDeleting || viewModel.isLoading)

            Text("Unit: \(viewModel.selectedUnit.shortLabel)")
                .font(.footnote)
                .foregroundStyle(AppTheme.muted)
        }
        .padding(14)
        .background(cardBackground)
    }

    private var consumedAtCard: some View {
        SimpleDateTimeInputCard(
            date: $viewModel.consumedAt,
            title: "Consumed At",
            subtitle: "Adjust when this hydration entry was consumed.",
            icon: "calendar.badge.clock",
            accent: AppTheme.accent
        )
        .allowsHitTesting(isSaving == false && isDeleting == false && viewModel.isLoading == false)
        .opacity((isSaving || isDeleting || viewModel.isLoading) ? 0.6 : 1)
    }

    private var healthKitSyncCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            fieldTitle("HealthKit Sync")
            Text(viewModel.syncStatusText)
                .font(.footnote)
                .foregroundStyle(AppTheme.muted)

            if viewModel.syncMetadata == nil {
                SimpleActionButton(
                    title: viewModel.isSyncingToHealthKit ? "Syncing..." : "Sync Entry to HealthKit",
                    systemImage: "arrow.triangle.2.circlepath.circle.fill",
                    tint: AppTheme.success,
                    style: .filled,
                    isEnabled: viewModel.isSyncingToHealthKit == false && viewModel.canSyncToHealthKit
                ) {
                    Task {
                        guard Task.isCancelled == false else {
                            return
                        }
                        await viewModel.syncPersistedEntryToHealthKit()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private var inputBackground: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.white.opacity(0.66))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(AppTheme.muted.opacity(0.2), lineWidth: 1)
            )
    }

    private func fieldTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .foregroundStyle(AppTheme.muted)
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            EditTodayEntryView(
                entryID: HydrationEntryIdentifier(value: UUID()),
                serviceContainer: PreviewServiceContainer()
            )
        }
    }
#endif
