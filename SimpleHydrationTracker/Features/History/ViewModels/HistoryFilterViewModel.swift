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

    private let historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol
    private var observationTask: Task<Void, Never>?
    private var hasStarted: Bool

    internal init(historyFilterPreferenceService: HistoryFilterPreferenceServiceProtocol) {
        self.historyFilterPreferenceService = historyFilterPreferenceService
        selection = .allTime
        includeQuickAdd = true
        includeCustomAmount = true
        includeEdited = true
        hasStarted = false
    }

    internal var hasChanges: Bool {
        selection != .allTime || includeQuickAdd == false || includeCustomAmount == false || includeEdited == false
    }

    internal func start() async {
        guard hasStarted == false else {
            return
        }
        hasStarted = true
        observationTask = Task {
            await observePreferences()
        }
    }

    internal func updateSelection(_ selection: HistoryFilterSelection) async {
        let updated = HistoryFilterPreferences(
            selection: selection,
            includeQuickAdd: includeQuickAdd,
            includeCustomAmount: includeCustomAmount,
            includeEdited: includeEdited
        )
        await historyFilterPreferenceService.updatePreferences(updated)
    }

    internal func updateIncludeQuickAdd(_ includeQuickAdd: Bool) async {
        let updated = HistoryFilterPreferences(
            selection: selection,
            includeQuickAdd: includeQuickAdd,
            includeCustomAmount: includeCustomAmount,
            includeEdited: includeEdited
        )
        await historyFilterPreferenceService.updatePreferences(updated)
    }

    internal func updateIncludeCustomAmount(_ includeCustomAmount: Bool) async {
        let updated = HistoryFilterPreferences(
            selection: selection,
            includeQuickAdd: includeQuickAdd,
            includeCustomAmount: includeCustomAmount,
            includeEdited: includeEdited
        )
        await historyFilterPreferenceService.updatePreferences(updated)
    }

    internal func updateIncludeEdited(_ includeEdited: Bool) async {
        let updated = HistoryFilterPreferences(
            selection: selection,
            includeQuickAdd: includeQuickAdd,
            includeCustomAmount: includeCustomAmount,
            includeEdited: includeEdited
        )
        await historyFilterPreferenceService.updatePreferences(updated)
    }

    internal func reset() async {
        await historyFilterPreferenceService.resetPreferences()
    }

    deinit {
        observationTask?.cancel()
    }

    private func observePreferences() async {
        let stream = await historyFilterPreferenceService.observePreferences()
        for await preferences in stream {
            guard Task.isCancelled == false else {
                return
            }
            selection = preferences.selection
            includeQuickAdd = preferences.includeQuickAdd
            includeCustomAmount = preferences.includeCustomAmount
            includeEdited = preferences.includeEdited
        }
    }
}
