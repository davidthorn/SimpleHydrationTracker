//
//  PreviewServiceContainer.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

#if DEBUG
    import Foundation
    import Models

    internal struct PreviewServiceContainer: ServiceContainerProtocol {
        internal let hydrationStore: HydrationStoreProtocol
        internal let goalStore: GoalStoreProtocol

        internal init() {
            hydrationStore = PreviewHydrationStore()
            goalStore = PreviewGoalStore()
        }
    }

    internal actor PreviewHydrationStore: HydrationStoreProtocol {
        internal func observeEntries() async throws -> AsyncStream<[HydrationEntry]> {
            let streamPair = AsyncStream<[HydrationEntry]>.makeStream()
            streamPair.continuation.yield([])
            return streamPair.stream
        }

        internal func fetchEntries() async throws -> [HydrationEntry] {
            []
        }

        internal func upsertEntry(_ entry: HydrationEntry) async throws {}

        internal func deleteEntry(id: HydrationEntryIdentifier) async throws {}
    }

    internal actor PreviewGoalStore: GoalStoreProtocol {
        internal func observeGoal() async throws -> AsyncStream<HydrationGoal?> {
            let streamPair = AsyncStream<HydrationGoal?>.makeStream()
            streamPair.continuation.yield(nil)
            return streamPair.stream
        }

        internal func fetchGoal() async throws -> HydrationGoal? {
            nil
        }

        internal func upsertGoal(_ goal: HydrationGoal) async throws {}

        internal func deleteGoal() async throws {}
    }
#endif
