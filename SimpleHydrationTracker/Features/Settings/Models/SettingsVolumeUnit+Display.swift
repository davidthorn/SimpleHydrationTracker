//
//  SettingsVolumeUnit+Display.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal extension SettingsVolumeUnit {
    var shortLabel: String {
        switch self {
        case .milliliters:
            return "ml"
        case .ounces:
            return "oz"
        }
    }

    var settingsValueLabel: String {
        switch self {
        case .milliliters:
            return "Milliliters"
        case .ounces:
            return "US Ounces"
        }
    }

    func format(milliliters: Int) -> String {
        switch self {
        case .milliliters:
            return "\(milliliters) \(shortLabel)"
        case .ounces:
            let ouncesTimesTen = Int((Double(milliliters) / 29.5735 * 10).rounded())
            if ouncesTimesTen % 10 == 0 {
                return "\(ouncesTimesTen / 10) \(shortLabel)"
            }
            return "\(Double(ouncesTimesTen) / 10) \(shortLabel)"
        }
    }

    func editableAmountText(milliliters: Int) -> String {
        switch self {
        case .milliliters:
            return "\(milliliters)"
        case .ounces:
            let ouncesTimesTen = Int((Double(milliliters) / 29.5735 * 10).rounded())
            if ouncesTimesTen % 10 == 0 {
                return "\(ouncesTimesTen / 10)"
            }
            return "\(Double(ouncesTimesTen) / 10)"
        }
    }

    func parseAmountText(_ text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return nil
        }

        switch self {
        case .milliliters:
            guard let value = Int(trimmed), value > 0 else {
                return nil
            }
            return value
        case .ounces:
            let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
            guard let value = Double(normalized), value > 0 else {
                return nil
            }
            return Int((value * 29.5735).rounded())
        }
    }
}
