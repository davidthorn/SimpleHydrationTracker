//
//  HistoryRoute.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models

internal enum HistoryRoute: Hashable {
    case dayDetail(dayID: HydrationDayIdentifier)
    case entryDetail(entryID: HydrationEntryIdentifier)
    case historyFilter
}
