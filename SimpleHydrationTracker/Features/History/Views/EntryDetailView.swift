//
//  EntryDetailView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI

internal struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EntryDetailViewModel
    @State private var showDeleteConfirmation: Bool
    @State private var isSaving: Bool
    @State private var isDeleting: Bool

    internal let entryID: HydrationEntryIdentifier

    internal init(entryID: HydrationEntryIdentifier, serviceContainer: ServiceContainerProtocol) {
        self.entryID = entryID
        let vm = EntryDetailViewModel(entryID: entryID, hydrationService: serviceContainer.hydrationService)
        _viewModel = StateObject(wrappedValue: vm)
        _showDeleteConfirmation = State(initialValue: false)
        _isSaving = State(initialValue: false)
        _isDeleting = State(initialValue: false)
    }

    internal var body: some View {
        Form {
            Section("Amount") {
                TextField("Milliliters", text: $viewModel.amountText)
                    .keyboardType(.numberPad)
            }

            Section("When") {
                DatePicker("Consumed At", selection: $viewModel.consumedAt)
            }

            Section("Source") {
                Text(viewModel.source?.rawValue ?? "Unknown")
                    .textCase(.none)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
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
                }
            }
        }
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
