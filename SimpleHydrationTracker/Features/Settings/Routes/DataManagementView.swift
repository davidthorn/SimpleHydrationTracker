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
            goalService: serviceContainer.goalService
        )
        _viewModel = StateObject(wrappedValue: vm)
        _showDeleteConfirmation = State(initialValue: false)
    }

    internal var body: some View {
        Form {
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
                Section("Export Result") {
                    Text(exportMessage)
                }
            }

            Section("Delete") {
                Button("Delete All Data", role: .destructive) {
                    showDeleteConfirmation = true
                }
                .disabled(viewModel.isExporting || viewModel.isDeletingAll)
            }

            if let errorMessage = viewModel.errorMessage {
                Section("Error") {
                    Text(errorMessage)
                        .foregroundStyle(AppTheme.error)
                    Button("Dismiss", role: .cancel) {
                        viewModel.clearMessages()
                    }
                }
            }
        }
        .navigationTitle("Data")
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
