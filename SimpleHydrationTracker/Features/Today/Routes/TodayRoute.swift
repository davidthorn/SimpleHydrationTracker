//
//  TodayRoute.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal enum TodayRoute: Hashable {
    case addCustomAmount
    case editTodayEntry(entryID: HydrationEntryIdentifier)
    case dayDetail(dayID: HydrationDayIdentifier)
    case goalSetup
}
