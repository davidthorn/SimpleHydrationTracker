//
//  TodayStatusCardComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct TodayStatusCardComponent: View {
    internal let title: String
    internal let message: String
    internal let systemImage: String
    internal let tint: Color

    internal var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .padding(8)
                .background(
                    Circle()
                        .fill(tint.opacity(0.14))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.muted)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(tint.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#if DEBUG
    #Preview {
        TodayStatusCardComponent(
            title: "Unable to Update",
            message: "Try again in a moment.",
            systemImage: "exclamationmark.triangle.fill",
            tint: AppTheme.error
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
