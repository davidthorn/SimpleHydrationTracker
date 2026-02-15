//
//  HistoryFilterSelection.swift
//  Models
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

public enum HistoryFilterSelection: String, CaseIterable, Identifiable, Codable, Sendable {
    case last7Days
    case last30Days
    case last90Days
    case allTime

    public var id: String {
        rawValue
    }

    public var title: String {
        switch self {
        case .last7Days:
            "Last 7 Days"
        case .last30Days:
            "Last 30 Days"
        case .last90Days:
            "Last 90 Days"
        case .allTime:
            "All Time"
        }
    }
}
