//
//  SipSizePreferenceService.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal actor SipSizePreferenceService: SipSizePreferenceServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let sipSizeKey = "settings.hydration.sipSize"
    private var continuations: [UUID: AsyncStream<SipSizeOption>.Continuation]

    internal init() {
        continuations = [:]
    }

    internal func observeSipSize() async -> AsyncStream<SipSizeOption> {
        let streamPair = AsyncStream<SipSizeOption>.makeStream()
        let id = UUID()
        continuations[id] = streamPair.continuation
        streamPair.continuation.onTermination = { [weak self] _ in
            guard let self else {
                return
            }
            Task {
                await self.removeContinuation(id: id)
            }
        }

        let current = await fetchSipSize()
        streamPair.continuation.yield(current)
        return streamPair.stream
    }

    internal func fetchSipSize() async -> SipSizeOption {
        let rawValue = userDefaults.integer(forKey: sipSizeKey)
        return SipSizeOption(rawValue: rawValue) ?? .ml30
    }

    internal func updateSipSize(_ sipSize: SipSizeOption) async {
        userDefaults.set(sipSize.rawValue, forKey: sipSizeKey)
        publish(sipSize)
    }

    internal func resetSipSize() async {
        userDefaults.removeObject(forKey: sipSizeKey)
        publish(.ml30)
    }

    private func removeContinuation(id: UUID) {
        continuations.removeValue(forKey: id)
    }

    private func publish(_ sipSize: SipSizeOption) {
        for continuation in continuations.values {
            continuation.yield(sipSize)
        }
    }
}
