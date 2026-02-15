//
//  HydrationStore.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal actor HydrationStore: HydrationStoreProtocol {
    private let fileName: String
    private let filePathResolver: StoreFilePathResolving
    private let codec: StoreJSONCodec

    private var cachedEntries: [HydrationEntry]
    private var hasLoaded: Bool
    private var streamContinuations: [UUID: AsyncStream<[HydrationEntry]>.Continuation]

    internal init(
        fileName: String = "hydration_entries.json",
        filePathResolver: StoreFilePathResolving = StoreFilePathResolver(),
        codec: StoreJSONCodec = StoreJSONCodec()
    ) {
        self.fileName = fileName
        self.filePathResolver = filePathResolver
        self.codec = codec
        cachedEntries = []
        hasLoaded = false
        streamContinuations = [:]
    }

    internal func observeEntries() async throws -> AsyncStream<[HydrationEntry]> {
        try await ensureLoaded()

        let streamID = UUID()
        let initialSnapshot = cachedEntries
        let streamPair = AsyncStream<[HydrationEntry]>.makeStream()

        streamPair.continuation.onTermination = { [weak self] _ in
            Task {
                await self?.removeStreamContinuation(streamID: streamID)
            }
        }

        streamContinuations[streamID] = streamPair.continuation
        streamPair.continuation.yield(initialSnapshot)

        return streamPair.stream
    }

    internal func fetchEntries() async throws -> [HydrationEntry] {
        try await ensureLoaded()
        return cachedEntries
    }

    internal func upsertEntry(_ entry: HydrationEntry) async throws {
        try await ensureLoaded()

        if let index = cachedEntries.firstIndex(where: { $0.id == entry.id }) {
            cachedEntries[index] = entry
        } else {
            cachedEntries.append(entry)
        }

        cachedEntries.sort { $0.consumedAt < $1.consumedAt }
        try await persistEntries()
        publishEntriesSnapshot()
    }

    internal func deleteEntry(id: HydrationEntryIdentifier) async throws {
        try await ensureLoaded()

        let previousCount = cachedEntries.count
        cachedEntries.removeAll { $0.id == id.value }

        guard cachedEntries.count != previousCount else {
            return
        }

        try await persistEntries()
        publishEntriesSnapshot()
    }

    private func ensureLoaded() async throws {
        guard hasLoaded == false else {
            return
        }

        cachedEntries = try await loadPersistedEntries()
        hasLoaded = true
    }

    private func loadPersistedEntries() async throws -> [HydrationEntry] {
        let fileURL = try await filePathResolver.fileURL(fileName: fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        guard data.isEmpty == false else {
            return []
        }

        return try codec.decoder.decode([HydrationEntry].self, from: data)
    }

    private func persistEntries() async throws {
        let fileURL = try await filePathResolver.fileURL(fileName: fileName)
        let encodedData = try codec.encoder.encode(cachedEntries)
        try encodedData.write(to: fileURL, options: .atomic)
    }

    private func publishEntriesSnapshot() {
        let snapshot = cachedEntries
        for continuation in streamContinuations.values {
            continuation.yield(snapshot)
        }
    }

    private func removeStreamContinuation(streamID: UUID) {
        streamContinuations.removeValue(forKey: streamID)
    }
}
