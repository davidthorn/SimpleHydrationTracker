//
//  HistoryRoute.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal enum HistoryRoute: Hashable {
    case dayDetail(date: Date)
    case entryDetail(entryID: UUID)
    case historyFilter
}
