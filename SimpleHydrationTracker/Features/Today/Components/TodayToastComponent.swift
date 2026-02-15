//
//  TodayToastComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct TodayToastComponent: View {
    internal let message: String
    internal let systemImage: String
    internal let tint: Color

    internal var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)

            Text(message)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(tint.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
    }
}

#if DEBUG
    #Preview {
        TodayToastComponent(
            message: "Added 250 ml",
            systemImage: "checkmark.circle.fill",
            tint: AppTheme.success
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
