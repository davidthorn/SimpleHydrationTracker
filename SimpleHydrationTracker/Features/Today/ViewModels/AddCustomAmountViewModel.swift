//
//  AddCustomAmountViewModel.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Combine
import Foundation
import Models

@MainActor
internal final class AddCustomAmountViewModel: ObservableObject {
    @Published internal var amountText: String
    @Published internal var consumedAt: Date
    @Published internal private(set) var errorMessage: String?

    private let hydrationService: HydrationServiceProtocol
    private let nowProvider: () -> Date

    internal init(
        hydrationService: HydrationServiceProtocol,
        nowProvider: @escaping () -> Date = { Date() }
    ) {
        self.hydrationService = hydrationService
        self.nowProvider = nowProvider
        amountText = ""
        consumedAt = nowProvider()
        errorMessage = nil
    }

    internal var canSave: Bool {
        guard let amount = Int(amountText.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return false
        }
        return amount > 0
    }

    internal func save() async throws {
        guard let amount = Int(amountText.trimmingCharacters(in: .whitespacesAndNewlines)), amount > 0 else {
            errorMessage = "Enter a valid amount greater than 0 ml."
            return
        }

        let entry = HydrationEntry(
            id: UUID(),
            amountMilliliters: amount,
            consumedAt: consumedAt,
            source: .customAmount
        )

        try await hydrationService.upsertEntry(entry)
        errorMessage = nil
    }
}
