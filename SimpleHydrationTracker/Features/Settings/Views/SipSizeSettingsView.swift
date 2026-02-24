//
//  SipSizeSettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Models
import SwiftUI
import SimpleFramework

internal struct SipSizeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SipSizeSettingsViewModel
    @State private var showDeleteConfirmation: Bool
    @State private var isSaving: Bool
    @State private var isDeleting: Bool

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = SipSizeSettingsViewModel(
            sipSizePreferenceService: serviceContainer.sipSizePreferenceService,
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
                        title: "Sip Size",
                        message: "Set a realistic sip amount so Quick Add supports healthy frequent logging.",
                        systemImage: "mouth",
                        tint: AppTheme.success
                    )

                    sipAmountCard
                    quickAddPreviewCard

                    if let errorMessage = viewModel.errorMessage {
                        SimpleFormErrorCard(message: errorMessage, tint: AppTheme.error)
                    }

                    SimpleFormActionButtons(
                        showSave: viewModel.canSave,
                        showReset: viewModel.canReset,
                        showDelete: viewModel.canDelete,
                        saveTitle: "Save Preference",
                        deleteTitle: "Delete Preference",
                        onSave: {
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                isSaving = true
                                defer { isSaving = false }
                                await viewModel.save()
                            }
                        },
                        onReset: {
                            viewModel.reset()
                        },
                        onDelete: {
                            showDeleteConfirmation = true
                        }
                    )
                    .opacity((viewModel.isLoading || isSaving || isDeleting) ? 0.6 : 1)
                    .allowsHitTesting(viewModel.isLoading == false && isSaving == false && isDeleting == false)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Sip Size")
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
                        title: "Delete sip size preference?",
                        message: "This removes your saved sip size and restores the default.",
                        confirmTitle: "Delete Preference",
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
                                await viewModel.delete()
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
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.loadIfNeeded()
        }
        .animation(.easeInOut(duration: 0.2), value: showDeleteConfirmation)
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading sip size...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var sipAmountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SimpleSectionTitleLabel(title: "Sip Amount", tint: AppTheme.muted)
            ForEach(SipSizeOption.allCases) { sipSize in
                SimpleSelectableCardRow(
                    title: viewModel.selectedUnit.format(milliliters: sipSize.milliliters),
                    subtitle: sipSize.recommendationLabel,
                    systemImage: "drop.fill",
                    tint: AppTheme.accent,
                    isSelected: viewModel.selectedSipSize == sipSize,
                    onToggleSelection: {
                        viewModel.selectedSipSize = sipSize
                    }
                )
                .allowsHitTesting(viewModel.isLoading == false && isSaving == false && isDeleting == false)
                .opacity(viewModel.isLoading || isSaving || isDeleting ? 0.6 : 1)
            }
        }
        .padding(14)
        .background(cardBackground)
    }

    private var quickAddPreviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SimpleSectionTitleLabel(title: "Quick Add Preview", tint: AppTheme.muted)
            Text("Small quick adds begin at \(viewModel.selectedUnit.format(milliliters: viewModel.selectedSipSize.milliliters)) and scale up by sip multiples.")
                .font(.subheadline)
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

}

#if DEBUG
    #Preview {
        NavigationStack {
            SipSizeSettingsView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
