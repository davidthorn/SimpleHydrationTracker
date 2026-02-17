//
//  EntryDetailView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI
import SimpleFramework

internal struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EntryDetailViewModel
    @State private var showDeleteConfirmation: Bool
    @State private var isSaving: Bool
    @State private var isDeleting: Bool

    internal let entryID: HydrationEntryIdentifier

    internal init(entryID: HydrationEntryIdentifier, serviceContainer: ServiceContainerProtocol) {
        self.entryID = entryID
        let vm = EntryDetailViewModel(
            entryID: entryID,
            hydrationService: serviceContainer.hydrationService,
            unitsPreferenceService: serviceContainer.unitsPreferenceService
        )
        _viewModel = StateObject(wrappedValue: vm)
        _showDeleteConfirmation = State(initialValue: false)
        _isSaving = State(initialValue: false)
        _isDeleting = State(initialValue: false)
    }

    internal var body: some View {
        Form {
            Section("Amount") {
                TextField(viewModel.selectedUnit.settingsValueLabel, text: $viewModel.amountText)
                    .keyboardType(
                        viewModel.selectedUnit == .milliliters
                            ? .numberPad
                            : .decimalPad
                    )
                    .disabled(viewModel.isLoading || isSaving || isDeleting)
                Text("Unit: \(viewModel.selectedUnit.shortLabel)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            Section("When") {
                DatePicker("Consumed At", selection: $viewModel.consumedAt)
                    .disabled(viewModel.isLoading || isSaving || isDeleting)
            }

            Section("Source") {
                Text(viewModel.source?.displayTitle ?? "Unknown")
                    .textCase(.none)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(AppTheme.error)
                }
            }

            if viewModel.canReset {
                Section {
                    Button("Reset", role: .cancel) {
                        viewModel.resetChanges()
                    }
                    .disabled(isSaving || isDeleting)
                }
            }

            if viewModel.canDelete {
                Section {
                    Button("Delete", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .disabled(isDeleting)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.pageGradient)
        .navigationTitle("Entry Detail")
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
        .alert("Are you sure you want to delete this?", isPresented: $showDeleteConfirmation) {
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
        }
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.loadIfNeeded()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading entry...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            EntryDetailView(
                entryID: HydrationEntryIdentifier(value: UUID()),
                serviceContainer: PreviewServiceContainer()
            )
        }
    }
#endif
