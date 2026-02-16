//
//  DataManagementView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct DataManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DataManagementViewModel
    @State private var showDeleteConfirmation: Bool

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = DataManagementViewModel(
            hydrationService: serviceContainer.hydrationService,
            goalService: serviceContainer.goalService,
            healthKitHydrationService: serviceContainer.healthKitHydrationService,
            hydrationEntrySyncMetadataService: serviceContainer.hydrationEntrySyncMetadataService
        )
        _viewModel = StateObject(wrappedValue: vm)
        _showDeleteConfirmation = State(initialValue: false)
    }

    internal var body: some View {
        Form {
            Section {
                SettingsHeroCardComponent(
                    title: "Data Management",
                    message: "Export records for review or delete all hydration and sync data when needed.",
                    systemImage: "tray.full",
                    tint: AppTheme.error
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Export") {
                Button("Prepare Export") {
                    Task {
                        guard Task.isCancelled == false else {
                            return
                        }
                        await viewModel.exportData()
                    }
                }
                .disabled(viewModel.isExporting || viewModel.isDeletingAll)
            }

            if let exportMessage = viewModel.exportResultMessage {
                Section {
                    SettingsStatusCardComponent(
                        title: "Export Ready",
                        message: exportMessage,
                        systemImage: "square.and.arrow.up",
                        tint: AppTheme.success
                    )
                }
            }

            Section("Delete") {
                Button("Delete All Data", role: .destructive) {
                    showDeleteConfirmation = true
                }
                .disabled(viewModel.isExporting || viewModel.isDeletingAll)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    SettingsStatusCardComponent(
                        title: "Data Error",
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle.fill",
                        tint: AppTheme.error
                    )
                    Button("Dismiss", role: .cancel) {
                        viewModel.clearMessages()
                    }
                }
            }
        }
        .navigationTitle("Data")
        .scrollContentBackground(.hidden)
        .background(AppTheme.pageGradient)
        .alert("Are you sure you want to delete this?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    guard Task.isCancelled == false else {
                        return
                    }
                    await viewModel.deleteAllData()
                    guard Task.isCancelled == false else {
                        return
                    }
                    dismiss()
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            DataManagementView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
