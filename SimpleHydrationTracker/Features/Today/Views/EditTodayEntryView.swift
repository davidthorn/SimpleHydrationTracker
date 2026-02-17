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
        Form {
            Section {
                TodayHeroCardComponent(
                    title: "Edit Entry",
                    message: "Adjust amount or time, then save your updated log.",
                    systemImage: "pencil.circle.fill",
                    tint: AppTheme.warning
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }

            Section("Amount") {
                TextField(viewModel.selectedUnit.settingsValueLabel, text: $viewModel.amountText)
                    .keyboardType(viewModel.selectedUnit == .milliliters ? .numberPad : .decimalPad)
                Text("Unit: \(viewModel.selectedUnit.shortLabel)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            Section("When") {
                DatePicker("Consumed At", selection: $viewModel.consumedAt)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    TodayStatusCardComponent(
                        title: "Unable to Update Entry",
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle.fill",
                        tint: AppTheme.error
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                }
            }

            if viewModel.hasPersistedEntry {
                Section("HealthKit Sync") {
                    Text(viewModel.syncStatusText)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.muted)

                    if viewModel.syncMetadata == nil {
                        Button(viewModel.isSyncingToHealthKit ? "Syncing..." : "Sync Entry to HealthKit") {
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                await viewModel.syncPersistedEntryToHealthKit()
                            }
                        }
                        .disabled(viewModel.isSyncingToHealthKit || viewModel.canSyncToHealthKit == false)
                    }
                }
            }

            if viewModel.canReset {
                Section {
                    Button("Reset", role: .cancel) {
                        viewModel.resetChanges()
                    }
                }
            }

            if viewModel.canDelete {
                Section {
                    Button("Delete", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .disabled(isDeleting)
                    .accessibilityHint("Permanently deletes this hydration entry.")
                }
            }
        }
        .navigationTitle("Edit Entry")
        .scrollContentBackground(.hidden)
        .background(AppTheme.pageGradient)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.canSave {
                    Button("Save") {
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
                    }
                    .disabled(isSaving)
                }
            }
        }
        .alert("Delete This Entry?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
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
                    }
                }
            }
        } message: {
            Text("This entry will be permanently removed from your hydration history.")
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
