//
//  HistoryDayMiniChartComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Charts
import Models
import SwiftUI

internal struct HistoryDayMiniChartComponent: View {
    internal let buckets: [HistoryDayIntakeBucket]
    internal let tint: Color

    internal var body: some View {
        Chart(buckets) { bucket in
            BarMark(
                x: .value("Bucket", bucket.id),
                y: .value("Intake", bucket.amountMilliliters)
            )
            .foregroundStyle(tint.opacity(bucket.amountMilliliters == 0 ? 0.25 : 0.9))
            .cornerRadius(4)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Daily intake pattern")
        .accessibilityValue(chartAccessibilityValue)
    }

    private var chartAccessibilityValue: String {
        guard buckets.isEmpty == false else {
            return "No hydration entries."
        }
        let nonZeroBucketCount = buckets.filter { $0.amountMilliliters > 0 }.count
        return "\(nonZeroBucketCount) active periods."
    }
}

#if DEBUG
    #Preview {
        HistoryDayMiniChartComponent(
            buckets: [
                HistoryDayIntakeBucket(id: 0, start: Date(), amountMilliliters: 250),
                HistoryDayIntakeBucket(id: 1, start: Date().addingTimeInterval(1800), amountMilliliters: 0),
                HistoryDayIntakeBucket(id: 2, start: Date().addingTimeInterval(3600), amountMilliliters: 300),
                HistoryDayIntakeBucket(id: 3, start: Date().addingTimeInterval(5400), amountMilliliters: 200)
            ],
            tint: AppTheme.accent
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
