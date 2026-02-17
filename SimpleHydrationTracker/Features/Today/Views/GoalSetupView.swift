//
//  GoalSetupView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI
import SimpleFramework

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
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SimpleHeroCard(
                        title: "Goal Setup",
                        message: "Define the target that drives your Today progress.",
                        systemImage: "target",
                        tint: AppTheme.accent
                    )

                    goalFormCard

                    if let errorMessage = viewModel.errorMessage {
                        SimpleFormErrorCard(message: errorMessage, tint: AppTheme.error)
                    }

                    SimpleFormActionButtons(
                        showSave: viewModel.canSave,
                        showReset: viewModel.canReset,
                        showDelete: viewModel.canDelete,
                        saveTitle: "Save Goal",
                        deleteTitle: "Delete Goal",
                        onSave: {
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
        .navigationTitle("Goal Setup")
        .tint(AppTheme.accent)
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.loadIfNeeded()
        }
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
                        title: "Delete current goal?",
                        message: "Your goal will be removed and progress targets will reset.",
                        confirmTitle: "Delete Goal",
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
                                    try await viewModel.deleteGoal()
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
        .animation(.easeInOut(duration: 0.2), value: showDeleteConfirmation)
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading goal...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var goalFormCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            fieldTitle("Daily Goal")
            TextField(viewModel.selectedUnit.settingsValueLabel, text: $viewModel.goalText)
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
            GoalSetupView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
