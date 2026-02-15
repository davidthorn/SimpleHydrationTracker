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

    private let hydrationService: HydrationServiceProtocol
    private let goalService: GoalServiceProtocol
    private let serviceContainer: ServiceContainerProtocol

    internal init() {
        let hydrationStore = HydrationStore()
        let goalStore = GoalStore()

        let serviceContainer = ServiceContainer(
            hydrationStore: hydrationStore,
            goalStore: goalStore
        )
        self.serviceContainer = serviceContainer
        hydrationService = serviceContainer.hydrationService
        goalService = serviceContainer.goalService

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
            #if DEBUG
                if let debugHydrationBootstrapService = hydrationService as? HydrationDebugBootstrapServiceProtocol {
                    try await debugHydrationBootstrapService.bootstrapIfNeeded()
                }
            #endif
            _ = try await hydrationService.fetchEntries()
            _ = try await goalService.fetchGoal()

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
