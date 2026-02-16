//
//  HydrationEntrySyncMetadataStoreProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 16.02.2026.
//

import Foundation
import Models

internal protocol HydrationEntrySyncMetadataStoreProtocol: Sendable {
    func observeMetadata() async throws -> AsyncStream<[HydrationEntrySyncMetadata]>
    func fetchMetadata() async throws -> [HydrationEntrySyncMetadata]
    func upsertMetadata(_ metadata: HydrationEntrySyncMetadata) async throws
    func deleteMetadata(for entryID: HydrationEntryIdentifier) async throws
    func deleteAllMetadata() async throws
}
