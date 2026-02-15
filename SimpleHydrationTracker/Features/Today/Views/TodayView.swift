//
//  TodayView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI

internal struct TodayView: View {
    @StateObject private var viewModel: TodayViewModel
    @State private var quickAddErrorMessage: String?
    private let quickAddOptions: [QuickAddAmount]

    internal init(
        serviceContainer: ServiceContainerProtocol,
        quickAddOptions: [QuickAddAmount] = QuickAddAmount.allCases
    ) {
        self.quickAddOptions = quickAddOptions
        let vm = TodayViewModel(
            hydrationStore: serviceContainer.hydrationStore,
            goalStore: serviceContainer.goalStore
        )
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                TodayProgressCardView(
                    consumedMilliliters: viewModel.state.consumedMilliliters,
                    goalMilliliters: viewModel.state.goalMilliliters,
                    remainingMilliliters: viewModel.state.remainingMilliliters,
                    progress: viewModel.state.progress
                )

                TodayQuickAddSectionView(quickAddOptions: quickAddOptions) { amount in
                    Task {
                        guard Task.isCancelled == false else {
                            return
                        }

                        do {
                            try await viewModel.addQuickAmount(amount)
                        } catch {
                            guard Task.isCancelled == false else {
                                return
                            }
                            quickAddErrorMessage = "Unable to add hydration right now."
                        }
                    }
                }

                if let errorMessage = viewModel.state.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                TodayRouteLinksSectionView()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle("Today")
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.start()
        }
        .alert("Unable to Add Water", isPresented: quickAddErrorAlertBinding) {
            Button("OK", role: .cancel) {
                quickAddErrorMessage = nil
            }
        } message: {
            Text(quickAddErrorMessage ?? "")
        }
    }

    private var quickAddErrorAlertBinding: Binding<Bool> {
        Binding(
            get: { quickAddErrorMessage != nil },
            set: { isPresented in
                if isPresented == false {
                    quickAddErrorMessage = nil
                }
            }
        )
    }
}

#if DEBUG
    #Preview {
        TodayView(serviceContainer: PreviewServiceContainer())
    }
#endif
