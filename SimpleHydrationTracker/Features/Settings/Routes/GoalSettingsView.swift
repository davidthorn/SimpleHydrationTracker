//
//  GoalSettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct GoalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GoalSettingsViewModel
    @State private var showDeleteConfirmation: Bool
    @State private var isSaving: Bool
    @State private var isDeleting: Bool

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = GoalSettingsViewModel(goalService: serviceContainer.goalService)
        _viewModel = StateObject(wrappedValue: vm)
        _showDeleteConfirmation = State(initialValue: false)
        _isSaving = State(initialValue: false)
        _isDeleting = State(initialValue: false)
    }

    internal var body: some View {
        Form {
            Section("Daily Goal") {
                TextField("Milliliters", text: $viewModel.goalText)
                    .keyboardType(.numberPad)
                    .disabled(isSaving || isDeleting || viewModel.isLoading)
            }

            if let errorMessage = viewModel.errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(AppTheme.error)
                }
            }

            if viewModel.canReset {
                Section {
                    Button("Reset", role: .cancel) {
                        viewModel.reset()
                    }
                    .disabled(isSaving || isDeleting)
                }
            }

            if viewModel.canDelete {
                Section {
                    Button("Delete Goal", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .disabled(isDeleting || isSaving)
                }
            }
        }
        .navigationTitle("Goal")
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
                                try await viewModel.save()
                            } catch {
                                guard Task.isCancelled == false else {
                                    return
                                }
                            }
                        }
                    }
                    .disabled(isSaving || isDeleting)
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
                        try await viewModel.delete()
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
                ProgressView("Loading goal...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            GoalSettingsView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
