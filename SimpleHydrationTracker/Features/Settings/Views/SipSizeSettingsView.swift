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
        Form {
            Section {
                SettingsHeroCardComponent(
                    title: "Sip Size",
                    message: "Set a realistic sip amount so Quick Add supports healthy frequent logging.",
                    systemImage: "mouth",
                    tint: AppTheme.success
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Sip Amount") {
                Picker("Sip Size", selection: $viewModel.selectedSipSize) {
                    ForEach(SipSizeOption.allCases) { sipSize in
                        Text("\(viewModel.selectedUnit.format(milliliters: sipSize.milliliters)) • \(sipSize.recommendationLabel)")
                            .tag(sipSize)
                    }
                }
                .disabled(viewModel.isLoading || isSaving || isDeleting)
            }

            Section("Quick Add Preview") {
                Text("Small quick adds begin at \(viewModel.selectedUnit.format(milliliters: viewModel.selectedSipSize.milliliters)) and scale up by sip multiples.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.muted)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    SettingsStatusCardComponent(
                        title: "Sip Size Error",
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle.fill",
                        tint: AppTheme.error
                    )
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
        .navigationTitle("Sip Size")
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
                ProgressView("Loading sip size...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            SipSizeSettingsView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
