//
//  HistoryFilterPreferences.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

public struct HistoryFilterPreferences: Codable, Hashable, Sendable {
    public let selection: HistoryFilterSelection
    public let includeQuickAdd: Bool
    public let includeCustomAmount: Bool
    public let includeEdited: Bool

    public init(
        selection: HistoryFilterSelection,
        includeQuickAdd: Bool,
        includeCustomAmount: Bool,
        includeEdited: Bool
    ) {
        self.selection = selection
        self.includeQuickAdd = includeQuickAdd
        self.includeCustomAmount = includeCustomAmount
        self.includeEdited = includeEdited
    }

    public static let `default` = HistoryFilterPreferences(
        selection: .allTime,
        includeQuickAdd: true,
        includeCustomAmount: true,
        includeEdited: true
    )
}
