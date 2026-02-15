//
//  HistoryDayIntakeBucket.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

public struct HistoryDayIntakeBucket: Identifiable, Hashable, Sendable {
    public let id: Int
    public let start: Date
    public let amountMilliliters: Int

    public init(
        id: Int,
        start: Date,
        amountMilliliters: Int
    ) {
        self.id = id
        self.start = start
        self.amountMilliliters = amountMilliliters
    }
}
