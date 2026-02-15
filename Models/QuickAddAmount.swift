//
//  QuickAddAmount.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

/// Preset hydration amounts used for quick logging.
public struct QuickAddAmount: Codable, Hashable, Identifiable, Sendable {
    public let milliliters: Int

    public var id: Int {
        milliliters
    }

    public init(milliliters: Int) {
        self.milliliters = max(milliliters, 1)
    }

    public var displayLabel: String {
        "+\(milliliters) ml"
    }

    public static func recommended(for sipSize: SipSizeOption) -> [QuickAddAmount] {
        let base = sipSize.milliliters
        let multiples = [
            base,
            base * 2,
            base * 3,
            base * 4
        ]
        let largerOptions = [250, 400, 600, 800]
        let allOptions = Set(multiples + largerOptions)
            .filter { $0 > 0 }
            .sorted()

        return allOptions.map { QuickAddAmount(milliliters: $0) }
    }
}
