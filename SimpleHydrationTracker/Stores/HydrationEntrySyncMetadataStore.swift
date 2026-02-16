//
//  HydrationEntrySyncMetadataStore.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 16.02.2026.
//

import Foundation
import Models

internal actor HydrationEntrySyncMetadataStore: HydrationEntrySyncMetadataStoreProtocol {
    private let fileName: String
    private let filePathResolver: StoreFilePathResolving
    private let codec: StoreJSONCodec

    private var cachedMetadata: [HydrationEntrySyncMetadata]
    private var hasLoaded: Bool
    private var streamContinuations: [UUID: AsyncStream<[HydrationEntrySyncMetadata]>.Continuation]

    internal init(
        fileName: String = "hydration_entry_sync_metadata.json",
        filePathResolver: StoreFilePathResolving = StoreFilePathResolver(),
        codec: StoreJSONCodec = StoreJSONCodec()
    ) {
        self.fileName = fileName
        self.filePathResolver = filePathResolver
        self.codec = codec
        cachedMetadata = []
        hasLoaded = false
        streamContinuations = [:]
    }

    internal func observeMetadata() async throws -> AsyncStream<[HydrationEntrySyncMetadata]> {
        try await ensureLoaded()

        let streamID = UUID()
        let initialSnapshot = cachedMetadata
        let streamPair = AsyncStream<[HydrationEntrySyncMetadata]>.makeStream()

        streamPair.continuation.onTermination = { [weak self] _ in
            Task {
                await self?.removeStreamContinuation(streamID: streamID)
            }
        }

        streamContinuations[streamID] = streamPair.continuation
        streamPair.continuation.yield(initialSnapshot)
        return streamPair.stream
    }

    internal func fetchMetadata() async throws -> [HydrationEntrySyncMetadata] {
        try await ensureLoaded()
        return cachedMetadata
    }

    internal func upsertMetadata(_ metadata: HydrationEntrySyncMetadata) async throws {
        try await ensureLoaded()

        if let index = cachedMetadata.firstIndex(where: { $0.entryID == metadata.entryID && $0.providerIdentifier == metadata.providerIdentifier }) {
            cachedMetadata[index] = metadata
        } else {
            cachedMetadata.append(metadata)
        }

        sortCachedMetadata()
        try await persistMetadata()
        publishMetadataSnapshot()
    }

    internal func deleteMetadata(for entryID: HydrationEntryIdentifier) async throws {
        try await ensureLoaded()

        let previousCount = cachedMetadata.count
        cachedMetadata.removeAll { $0.entryID == entryID.value }

        guard previousCount != cachedMetadata.count else {
            return
        }

        try await persistMetadata()
        publishMetadataSnapshot()
    }

    internal func deleteAllMetadata() async throws {
        try await ensureLoaded()
        guard cachedMetadata.isEmpty == false else {
            return
        }

        cachedMetadata.removeAll()
        try await persistMetadata()
        publishMetadataSnapshot()
    }

    private func ensureLoaded() async throws {
        guard hasLoaded == false else {
            return
        }

        cachedMetadata = try await loadPersistedMetadata()
        sortCachedMetadata()
        hasLoaded = true
    }

    private func loadPersistedMetadata() async throws -> [HydrationEntrySyncMetadata] {
        let fileURL = try await filePathResolver.fileURL(fileName: fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        guard data.isEmpty == false else {
            return []
        }

        return try codec.decoder.decode([HydrationEntrySyncMetadata].self, from: data)
    }

    private func persistMetadata() async throws {
        let fileURL = try await filePathResolver.fileURL(fileName: fileName)
        let encodedData = try codec.encoder.encode(cachedMetadata)
        try encodedData.write(to: fileURL, options: .atomic)
    }

    private func sortCachedMetadata() {
        cachedMetadata.sort { $0.syncedAt > $1.syncedAt }
    }

    private func publishMetadataSnapshot() {
        let snapshot = cachedMetadata
        for continuation in streamContinuations.values {
            continuation.yield(snapshot)
        }
    }

    private func removeStreamContinuation(streamID: UUID) {
        streamContinuations.removeValue(forKey: streamID)
    }
}
