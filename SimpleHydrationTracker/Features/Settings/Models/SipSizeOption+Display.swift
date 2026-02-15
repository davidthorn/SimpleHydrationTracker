//
//  SipSizeOption+Display.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal extension SipSizeOption {
    var recommendationLabel: String {
        switch self {
        case .ml15:
            return "Very Small"
        case .ml20:
            return "Small"
        case .ml30:
            return "Standard"
        case .ml45:
            return "Medium"
        case .ml60:
            return "Large"
        case .ml90:
            return "Very Large"
        @unknown default:
            return "Custom"
        }
    }
}
