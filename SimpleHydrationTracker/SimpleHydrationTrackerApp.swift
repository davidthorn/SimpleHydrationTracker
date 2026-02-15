//
//  SimpleHydrationTrackerApp.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.26.
//

import SwiftUI

@main
internal struct SimpleHydrationTrackerApp: App {
    @State private var launchState: AppLaunchState

    private let hydrationStore: HydrationStoreProtocol
    private let goalStore: GoalStoreProtocol
    private let serviceContainer: ServiceContainerProtocol

    internal init() {
        let hydrationStore = HydrationStore()
        let goalStore = GoalStore()

        self.hydrationStore = hydrationStore
        self.goalStore = goalStore
        serviceContainer = ServiceContainer(
            hydrationStore: hydrationStore,
            goalStore: goalStore
        )

        _launchState = State(initialValue: .loading)
    }

    internal var body: some Scene {
        WindowGroup {
            Group {
                switch launchState {
                case .loading:
                    LaunchLoadingView()
                case .ready:
                    ContentView(serviceContainer: serviceContainer)
                case .failed(let message):
                    LaunchErrorView(message: message)
                }
            }
            .task {
                await preloadPersistedDataIfNeeded()
            }
        }
    }

    @MainActor
    private func preloadPersistedDataIfNeeded() async {
        guard launchState == .loading else {
            return
        }

        do {
            _ = try await hydrationStore.fetchEntries()
            _ = try await goalStore.fetchGoal()

            guard Task.isCancelled == false else {
                return
            }

            launchState = .ready
        } catch {
            guard Task.isCancelled == false else {
                return
            }

            launchState = .failed(message: "Unable to load saved hydration data.")
        }
    }
}
