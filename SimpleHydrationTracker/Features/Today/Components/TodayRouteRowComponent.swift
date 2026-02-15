//
//  TodayRouteRowComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct TodayRouteRowComponent: View {
    internal let title: String
    internal let subtitle: String
    internal let systemImage: String
    internal let tint: Color
    internal let isEnabled: Bool

    internal init(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        isEnabled: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.isEnabled = isEnabled
    }

    internal var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundStyle(isEnabled ? tint : AppTheme.muted)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill((isEnabled ? tint : AppTheme.muted).opacity(0.14))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isEnabled ? .primary : AppTheme.muted)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.muted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
        .opacity(isEnabled ? 1 : 0.7)
    }
}

#if DEBUG
    #Preview {
        VStack(spacing: 12) {
            TodayRouteRowComponent(
                title: "Add Custom Amount",
                subtitle: "Log a specific intake",
                systemImage: "plus.circle",
                tint: AppTheme.accent
            )
            TodayRouteRowComponent(
                title: "Edit Latest Entry",
                subtitle: "Unavailable until an entry exists",
                systemImage: "pencil",
                tint: AppTheme.warning,
                isEnabled: false
            )
        }
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
