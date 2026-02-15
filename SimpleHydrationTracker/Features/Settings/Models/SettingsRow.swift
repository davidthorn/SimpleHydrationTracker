//
//  SettingsRow.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct SettingsRow: Identifiable {
    internal let id: UUID
    internal let route: SettingsRoute
    internal let title: String
    internal let subtitle: String
    internal let systemImage: String
    internal let tint: Color

    internal init(route: SettingsRoute, title: String, subtitle: String, systemImage: String, tint: Color) {
        id = UUID()
        self.route = route
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
    }
}
