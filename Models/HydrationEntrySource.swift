//
//  HydrationEntrySource.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

/// Represents where a hydration entry originated.
public enum HydrationEntrySource: String, Codable, Hashable, Sendable {
    case quickAdd
    case customAmount
    case edited

    /// User-facing text for forms and detail rows.
    public var displayTitle: String {
        switch self {
        case .quickAdd:
            "Quick Add"
        case .customAmount:
            "Custom Amount"
        case .edited:
            "Edited"
        }
    }
}
