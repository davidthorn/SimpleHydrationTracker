//
//  AddCustomAmountView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI
import SimpleFramework

internal struct AddCustomAmountView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddCustomAmountViewModel
    @State private var isSaving: Bool

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = AddCustomAmountViewModel(
            hydrationService: serviceContainer.hydrationService,
            unitsPreferenceService: serviceContainer.unitsPreferenceService,
            sipSizePreferenceService: serviceContainer.sipSizePreferenceService,
            healthKitHydrationService: serviceContainer.healthKitHydrationService,
            hydrationEntrySyncMetadataService: serviceContainer.hydrationEntrySyncMetadataService
        )
        _viewModel = StateObject(wrappedValue: vm)
        _isSaving = State(initialValue: false)
    }

    internal var body: some View {
        Form {
            Section {
                SimpleHeroCard(
                    title: "Add Custom Amount",
                    message: "Log any amount for precise daily tracking.",
                    systemImage: "plus.circle.fill",
                    tint: AppTheme.accent
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }

            Section("Amount") {
                SimpleLabeledTextFieldCard(
                    numericText: $viewModel.amountText,
                    title: "Amount",
                    placeholder: viewModel.selectedUnit.settingsValueLabel,
                    helperText: "Unit: \(viewModel.selectedUnit.shortLabel)",
                    tint: AppTheme.accent,
                    isEnabled: isSaving == false,
                    allowsDecimalInput: viewModel.selectedUnit == .ounces
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }

            Section {
                TodayQuickAddSectionView(
                    quickAddOptions: viewModel.quickAddOptions,
                    selectedUnit: viewModel.selectedUnit
                ) { amount in
                    viewModel.prefillAmount(using: amount)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }

            Section {
                SimpleDateTimeInputCard(
                    date: $viewModel.consumedAt,
                    title: "Consumed At",
                    subtitle: "Adjust when this hydration entry was consumed.",
                    icon: "calendar.badge.clock",
                    accent: AppTheme.accent
                )
                .allowsHitTesting(isSaving == false)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    SimpleStatusCard(
                        title: "Unable to Save",
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle.fill",
                        tint: AppTheme.error
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                }
            }
        }
        .navigationTitle("Add Amount")
        .scrollContentBackground(.hidden)
        .background(AppTheme.pageGradient)
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.start()
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
                                try await viewModel.save()
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
                    .disabled(isSaving)
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            AddCustomAmountView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
