//
//  TodayHeroCardComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct TodayHeroCardComponent: View {
    internal let title: String
    internal let message: String
    internal let systemImage: String
    internal let tint: Color

    internal var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(AppTheme.muted)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(tint.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#if DEBUG
    #Preview {
        TodayHeroCardComponent(
            title: "Build Your Daily Rhythm",
            message: "Track progress, log quickly, and stay aligned with your goal.",
            systemImage: "drop.circle.fill",
            tint: AppTheme.accent
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
