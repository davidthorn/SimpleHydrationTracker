//
//  AppTheme.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal enum AppTheme {
    internal static let pageGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.97, blue: 1.0),
            Color(red: 0.98, green: 0.99, blue: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    internal static let cardBackground = Color.white.opacity(0.92)
    internal static let accent = Color(red: 0.08, green: 0.39, blue: 0.62)
    internal static let muted = Color(red: 0.32, green: 0.36, blue: 0.42)
    internal static let error = Color.red
}
