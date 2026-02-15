//
//  GoalSetupView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct GoalSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GoalSetupViewModel
    @State private var showDeleteConfirmation: Bool
    @State private var isSaving: Bool
    @State private var isDeleting: Bool

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = GoalSetupViewModel(
            goalService: serviceContainer.goalService,
            unitsPreferenceService: serviceContainer.unitsPreferenceService
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
                    title: "Goal Setup",
                    message: "Define the target that drives your Today progress.",
                    systemImage: "target",
                    tint: AppTheme.accent
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }

            Section("Daily Goal") {
                TextField(viewModel.selectedUnit.settingsValueLabel, text: $viewModel.goalText)
                    .keyboardType(viewModel.selectedUnit == .milliliters ? .numberPad : .decimalPad)
                Text("Unit: \(viewModel.selectedUnit.shortLabel)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    TodayStatusCardComponent(
                        title: "Unable to Update Goal",
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle.fill",
                        tint: AppTheme.error
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
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
        .navigationTitle("Goal Setup")
        .scrollContentBackground(.hidden)
        .background(AppTheme.pageGradient)
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.loadIfNeeded()
        }
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
                                try await viewModel.saveGoal()
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
                        try await viewModel.deleteGoal()
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
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            GoalSetupView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
