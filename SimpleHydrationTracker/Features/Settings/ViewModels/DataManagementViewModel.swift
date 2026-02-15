//
//  DataManagementViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class DataManagementViewModel: ObservableObject {
    @Published internal private(set) var isExporting: Bool
    @Published internal private(set) var isDeletingAll: Bool
    @Published internal private(set) var errorMessage: String?
    @Published internal private(set) var exportResultMessage: String?

    private let hydrationService: HydrationServiceProtocol
    private let goalService: GoalServiceProtocol

    internal init(
        hydrationService: HydrationServiceProtocol,
        goalService: GoalServiceProtocol
    ) {
        self.hydrationService = hydrationService
        self.goalService = goalService
        isExporting = false
        isDeletingAll = false
        errorMessage = nil
        exportResultMessage = nil
    }

    internal func exportData() async {
        isExporting = true
        defer { isExporting = false }

        do {
            let entries = try await hydrationService.fetchEntries()
            let goal = try await goalService.fetchGoal()
            exportResultMessage = "Prepared export payload with \(entries.count) entries and goal: \(goal != nil ? "present" : "none")."
            errorMessage = nil
        } catch {
            errorMessage = "Unable to export hydration data."
        }
    }

    internal func deleteAllData() async {
        isDeletingAll = true
        defer { isDeletingAll = false }

        do {
            let entries = try await hydrationService.fetchEntries()
            for entry in entries {
                try await hydrationService.deleteEntry(id: HydrationEntryIdentifier(value: entry.id))
            }
            try await goalService.deleteGoal()
            exportResultMessage = nil
            errorMessage = nil
        } catch {
            errorMessage = "Unable to delete all hydration data."
        }
    }

    internal func clearMessages() {
        errorMessage = nil
        exportResultMessage = nil
    }
}
