//
//  TodayRoute.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal enum TodayRoute: Hashable {
    case addCustomAmount
    case editTodayEntry(entryID: UUID)
    case dayDetail(date: Date)
    case goalSetup
}
