//
//  SettingsRouteSectionComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct SettingsRouteSectionComponent: View {
    internal let title: String
    internal let rows: [SettingsRow]

    internal var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.muted)
                .textCase(.uppercase)

            VStack(spacing: 8) {
                ForEach(rows) { row in
                    NavigationLink(value: row.route) {
                        SettingsRouteRowComponent(
                            title: row.title,
                            subtitle: row.subtitle,
                            systemImage: row.systemImage,
                            tint: row.tint
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        SettingsRouteSectionComponent(
            title: "Hydration",
            rows: [
                SettingsRow(
                    route: .goalSettings,
                    title: "Goal",
                    subtitle: "Daily target",
                    systemImage: "target",
                    tint: AppTheme.success
                )
            ]
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
