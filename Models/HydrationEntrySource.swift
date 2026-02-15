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
}
