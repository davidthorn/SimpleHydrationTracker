//
//  UnitsSettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI
import SimpleFramework

internal struct UnitsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: UnitsSettingsViewModel
    @State private var showDeleteConfirmation: Bool
    @State private var isSaving: Bool
    @State private var isDeleting: Bool
    private let unitOptions: [SimpleSegmentedChoiceOption]

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = UnitsSettingsViewModel(unitsService: serviceContainer.unitsPreferenceService)
        _viewModel = StateObject(wrappedValue: vm)
        _showDeleteConfirmation = State(initialValue: false)
        _isSaving = State(initialValue: false)
        _isDeleting = State(initialValue: false)
        unitOptions = SettingsVolumeUnit.allCases.map { unit in
            SimpleSegmentedChoiceOption(title: unit.shortLabel.uppercased(), value: unit.rawValue)
        }
    }

    internal var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SimpleHeroCard(
                        title: "Display Units",
                        message: "Choose how hydration values appear across the app.",
                        systemImage: "ruler",
                        tint: AppTheme.accent
                    )

                    SimpleSegmentedChoiceCard(
                        selectedValue: selectedUnitBinding,
                        title: "Volume Unit",
                        options: unitOptions
                    )
                    .opacity((viewModel.isLoading || isSaving || isDeleting) ? 0.6 : 1)
                    .allowsHitTesting(viewModel.isLoading == false && isSaving == false && isDeleting == false)

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
        .navigationTitle("Units")
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
                        title: "Delete unit preference?",
                        message: "This removes your saved unit and restores milliliters.",
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
                ProgressView("Loading units...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var selectedUnitBinding: Binding<String> {
        Binding(
            get: { viewModel.selectedUnit.rawValue },
            set: { value in
                if let unit = SettingsVolumeUnit(rawValue: value) {
                    viewModel.selectedUnit = unit
                }
            }
        )
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            UnitsSettingsView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
