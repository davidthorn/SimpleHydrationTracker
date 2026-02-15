//
//  UnitsSettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct UnitsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: UnitsSettingsViewModel
    @State private var showDeleteConfirmation: Bool
    @State private var isSaving: Bool
    @State private var isDeleting: Bool

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = UnitsSettingsViewModel(unitsService: serviceContainer.unitsPreferenceService)
        _viewModel = StateObject(wrappedValue: vm)
        _showDeleteConfirmation = State(initialValue: false)
        _isSaving = State(initialValue: false)
        _isDeleting = State(initialValue: false)
    }

    internal var body: some View {
        Form {
            Section("Unit") {
                Picker("Volume Unit", selection: $viewModel.selectedUnit) {
                    ForEach(SettingsVolumeUnit.allCases) { unit in
                        Text(unit.title).tag(unit)
                    }
                }
                .disabled(viewModel.isLoading || isSaving || isDeleting)
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
                    Button("Delete Preference", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .disabled(isSaving || isDeleting)
                }
            }
        }
        .navigationTitle("Units")
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
                            await viewModel.save()
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
                    await viewModel.delete()
                    guard Task.isCancelled == false else {
                        return
                    }
                    dismiss()
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
                ProgressView("Loading units...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            UnitsSettingsView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
