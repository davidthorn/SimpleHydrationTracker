//
//  HistoryFilterViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class HistoryFilterViewModel: ObservableObject {
    @Published internal var selection: HistoryFilterSelection
    @Published internal var includeQuickAdd: Bool
    @Published internal var includeCustomAmount: Bool
    @Published internal var includeEdited: Bool

    internal init() {
        selection = .allTime
        includeQuickAdd = true
        includeCustomAmount = true
        includeEdited = true
    }

    internal var hasChanges: Bool {
        selection != .allTime || includeQuickAdd == false || includeCustomAmount == false || includeEdited == false
    }

    internal func reset() {
        selection = .allTime
        includeQuickAdd = true
        includeCustomAmount = true
        includeEdited = true
    }
}
