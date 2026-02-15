//
//  HydrationServiceProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal protocol HydrationServiceProtocol: Sendable {
    func observeEntries() async throws -> AsyncStream<[HydrationEntry]>
    func fetchEntries() async throws -> [HydrationEntry]
    func upsertEntry(_ entry: HydrationEntry) async throws
    func deleteEntry(id: HydrationEntryIdentifier) async throws
}
