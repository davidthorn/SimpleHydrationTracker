//
//  SipSizeOption.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

public enum SipSizeOption: Int, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case ml15 = 15
    case ml20 = 20
    case ml30 = 30
    case ml45 = 45
    case ml60 = 60
    case ml90 = 90

    public var id: Int {
        rawValue
    }

    public var milliliters: Int {
        rawValue
    }
}
