//
//  HydrationService+DebugBootstrap.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

#if DEBUG
    import Foundation
    import Models

    extension HydrationService: HydrationDebugBootstrapServiceProtocol {
        internal func bootstrapIfNeeded() async throws {
            let existingEntries = try await hydrationStore.fetchEntries()
            guard existingEntries.isEmpty else {
                return
            }

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            guard
                let dayOne = calendar.date(byAdding: .day, value: -2, to: today),
                let dayTwo = calendar.date(byAdding: .day, value: -1, to: today)
            else {
                return
            }

            // Baseline complete-day total: 1,500 ml. Today is 60%: 900 ml.
            let dayOneEntries = buildEntries(
                for: dayOne,
                startHour: 7,
                startMinute: 0,
                intervalMinutes: 20,
                sipCount: 44,
                bigSipIndices: [8, 23, 37]
            )
            let dayTwoEntries = buildEntries(
                for: dayTwo,
                startHour: 7,
                startMinute: 10,
                intervalMinutes: 20,
                sipCount: 44,
                bigSipIndices: [6, 19, 34]
            )
            let dayThreeEntries = buildEntries(
                for: today,
                startHour: 7,
                startMinute: 20,
                intervalMinutes: 20,
                sipCount: 28,
                bigSipIndices: [15]
            )

            let seededEntries = dayOneEntries + dayTwoEntries + dayThreeEntries
            for entry in seededEntries {
                try await hydrationStore.upsertEntry(entry)
            }
        }

        private func buildEntries(
            for day: Date,
            startHour: Int,
            startMinute: Int,
            intervalMinutes: Int,
            sipCount: Int,
            bigSipIndices: [Int]
        ) -> [HydrationEntry] {
            let calendar = Calendar.current
            let bigSipIndexSet = Set(bigSipIndices)

            return (0..<sipCount).compactMap { (index: Int) -> HydrationEntry? in
                let totalMinutes = startHour * 60 + startMinute + (index * intervalMinutes)
                let hour = totalMinutes / 60
                let minute = totalMinutes % 60

                var components = calendar.dateComponents([.year, .month, .day], from: day)
                components.hour = hour
                components.minute = minute
                components.second = 0

                guard let consumedAt = calendar.date(from: components) else {
                    return nil
                }

                let amount = bigSipIndexSet.contains(index) ? 90 : 30
                return HydrationEntry(
                    id: UUID(),
                    amountMilliliters: amount,
                    consumedAt: consumedAt,
                    source: amount == 90 ? .customAmount : .quickAdd
                )
            }
        }
    }
#endif
