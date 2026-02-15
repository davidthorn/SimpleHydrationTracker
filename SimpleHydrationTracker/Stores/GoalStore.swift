//
//  GoalStore.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal actor GoalStore: GoalStoreProtocol {
    private let fileName: String
    private let filePathResolver: StoreFilePathResolving
    private let codec: StoreJSONCodec

    private var cachedGoal: HydrationGoal?
    private var hasLoaded: Bool
    private var streamContinuations: [UUID: AsyncStream<HydrationGoal?>.Continuation]

    internal init(
        fileName: String = "hydration_goal.json",
        filePathResolver: StoreFilePathResolving = StoreFilePathResolver(),
        codec: StoreJSONCodec = StoreJSONCodec()
    ) {
        self.fileName = fileName
        self.filePathResolver = filePathResolver
        self.codec = codec
        cachedGoal = nil
        hasLoaded = false
        streamContinuations = [:]
    }

    internal func observeGoal() async throws -> AsyncStream<HydrationGoal?> {
        try await ensureLoaded()

        let streamID = UUID()
        let initialSnapshot = cachedGoal
        let streamPair = AsyncStream<HydrationGoal?>.makeStream()

        streamPair.continuation.onTermination = { [weak self] _ in
            Task {
                await self?.removeStreamContinuation(streamID: streamID)
            }
        }

        streamContinuations[streamID] = streamPair.continuation
        streamPair.continuation.yield(initialSnapshot)

        return streamPair.stream
    }

    internal func fetchGoal() async throws -> HydrationGoal? {
        try await ensureLoaded()
        return cachedGoal
    }

    internal func upsertGoal(_ goal: HydrationGoal) async throws {
        try await ensureLoaded()
        cachedGoal = goal
        try await persistGoal()
        publishGoalSnapshot()
    }

    internal func deleteGoal() async throws {
        try await ensureLoaded()

        guard cachedGoal != nil else {
            return
        }

        cachedGoal = nil
        try await persistGoal()
        publishGoalSnapshot()
    }

    private func ensureLoaded() async throws {
        guard hasLoaded == false else {
            return
        }

        cachedGoal = try await loadPersistedGoal()
        hasLoaded = true
    }

    private func loadPersistedGoal() async throws -> HydrationGoal? {
        let fileURL = try await filePathResolver.fileURL(fileName: fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        guard data.isEmpty == false else {
            return nil
        }

        return try codec.decoder.decode(HydrationGoal.self, from: data)
    }

    private func persistGoal() async throws {
        let fileURL = try await filePathResolver.fileURL(fileName: fileName)

        if let goal = cachedGoal {
            let encodedData = try codec.encoder.encode(goal)
            try encodedData.write(to: fileURL, options: .atomic)
            return
        }

        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    private func publishGoalSnapshot() {
        let snapshot = cachedGoal
        for continuation in streamContinuations.values {
            continuation.yield(snapshot)
        }
    }

    private func removeStreamContinuation(streamID: UUID) {
        streamContinuations.removeValue(forKey: streamID)
    }
}
