//
//  TodayIntakeChartCardComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Charts
import SwiftUI

internal struct TodayIntakeChartCardComponent: View {
    internal let chartData: TodayIntakeChartData
    internal let selectedUnit: SettingsVolumeUnit

    internal var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Intake Trend")
                    .font(.headline)
                Text("Adaptive fluid intake trend for today (\(selectedUnit.shortLabel)).")
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            if chartData.points.isEmpty {
                Text("Add hydration entries to display today's intake trend.")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                Chart(chartData.points) { point in
                    BarMark(
                        x: .value("Time", point.hourStart),
                        y: .value("Amount", displayAmount(from: point.totalMilliliters))
                    )
                    .foregroundStyle(AppTheme.accent.gradient)
                    .cornerRadius(5)
                }
                .frame(height: 180)
                .chartXScale(domain: chartDomain)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .minute, count: axisLabelMinuteStrideCount)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.hour().minute())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
    }

    private func displayAmount(from milliliters: Int) -> Double {
        switch selectedUnit {
        case .milliliters:
            return Double(milliliters)
        case .ounces:
            return Double(milliliters) / 29.5735
        }
    }

    private var chartDomain: ClosedRange<Date> {
        guard let first = chartData.points.first?.hourStart, let last = chartData.points.last?.hourStart else {
            let now = Date()
            return now...now
        }
        let padding = chartData.scale.bucketSeconds
        return first...last.addingTimeInterval(padding)
    }

    private var axisLabelMinuteStrideCount: Int {
        switch chartData.scale {
        case .fiveMinutes:
            return 30
        case .fifteenMinutes:
            return 30
        case .thirtyMinutes:
            return 60
        case .hourly:
            return 120
        }
    }
}

#if DEBUG
    #Preview {
        TodayIntakeChartCardComponent(
            chartData: TodayIntakeChartData(
                points: [
                    TodayIntakeChartPoint(hourStart: Date().addingTimeInterval(-60 * 60 * 3), totalMilliliters: 350),
                    TodayIntakeChartPoint(hourStart: Date().addingTimeInterval(-60 * 60 * 2), totalMilliliters: 250),
                    TodayIntakeChartPoint(hourStart: Date().addingTimeInterval(-60 * 60), totalMilliliters: 500)
                ],
                scale: .fifteenMinutes
            ),
            selectedUnit: .milliliters
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
