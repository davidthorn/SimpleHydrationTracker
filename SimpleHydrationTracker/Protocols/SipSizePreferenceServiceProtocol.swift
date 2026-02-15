//
//  SipSizePreferenceServiceProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal protocol SipSizePreferenceServiceProtocol: Sendable {
    func observeSipSize() async -> AsyncStream<SipSizeOption>
    func fetchSipSize() async -> SipSizeOption
    func updateSipSize(_ sipSize: SipSizeOption) async
    func resetSipSize() async
}
