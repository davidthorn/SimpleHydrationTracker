//
//  StoreJSONCodec.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal struct StoreJSONCodec {
    internal let encoder: JSONEncoder
    internal let decoder: JSONDecoder

    internal init() {
        let configuredEncoder = JSONEncoder()
        configuredEncoder.dateEncodingStrategy = .iso8601
        configuredEncoder.outputFormatting = [.sortedKeys]

        let configuredDecoder = JSONDecoder()
        configuredDecoder.dateDecodingStrategy = .iso8601

        encoder = configuredEncoder
        decoder = configuredDecoder
    }
}
