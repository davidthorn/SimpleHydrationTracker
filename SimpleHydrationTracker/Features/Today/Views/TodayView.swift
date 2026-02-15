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

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = TodayViewModel(
            hydrationStore: serviceContainer.hydrationStore,
            goalStore: serviceContainer.goalStore
        )
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        List {
            Section("Today Summary") {
                Text("Consumed: \(viewModel.state.consumedMilliliters) ml")
                Text("Goal: \(viewModel.state.goalMilliliters) ml")
                Text("Remaining: \(viewModel.state.remainingMilliliters) ml")
                Text("Progress: \(Int(viewModel.state.progress * 100))%")
                if let errorMessage = viewModel.state.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            NavigationLink(value: TodayRoute.addCustomAmount) {
                Text("Add Custom Amount")
            }
            NavigationLink(
                value: TodayRoute.editTodayEntry(entryID: HydrationEntryIdentifier(value: UUID()))
            ) {
                Text("Edit Today Entry")
            }
            NavigationLink(
                value: TodayRoute.dayDetail(dayID: HydrationDayIdentifier(value: Date()))
            ) {
                Text("Day Detail")
            }
            NavigationLink(value: TodayRoute.goalSetup) {
                Text("Goal Setup")
            }
        }
        .navigationTitle("Today")
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.start()
        }
    }
}

#if DEBUG
    #Preview {
        TodayView(serviceContainer: PreviewServiceContainer())
    }
#endif
