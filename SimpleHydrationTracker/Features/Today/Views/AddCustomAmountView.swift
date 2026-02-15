//
//  AddCustomAmountView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct AddCustomAmountView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddCustomAmountViewModel
    @State private var isSaving: Bool

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = AddCustomAmountViewModel(hydrationService: serviceContainer.hydrationService)
        _viewModel = StateObject(wrappedValue: vm)
        _isSaving = State(initialValue: false)
    }

    internal var body: some View {
        Form {
            Section("Amount") {
                TextField("Milliliters", text: $viewModel.amountText)
                    .keyboardType(.numberPad)
            }

            Section("When") {
                DatePicker("Consumed At", selection: $viewModel.consumedAt)
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Add Amount")
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
