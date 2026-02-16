//
//  HealthKitAutoSyncCardComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 16.02.2026.
//

import SwiftUI

internal struct HealthKitAutoSyncCardComponent: View {
    @Binding private var isAutoSyncEnabled: Bool
    private let isHealthKitAvailable: Bool

    internal init(isAutoSyncEnabled: Binding<Bool>, isHealthKitAvailable: Bool) {
        _isAutoSyncEnabled = isAutoSyncEnabled
        self.isHealthKitAvailable = isHealthKitAvailable
    }

    internal var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.success)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(AppTheme.success.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Automatic Sync")
                    .font(.subheadline.weight(.semibold))
                Text("When enabled, newly created hydration logs are also saved to HealthKit.")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.muted)
            }

            Spacer()

            Toggle("", isOn: $isAutoSyncEnabled)
                .labelsHidden()
                .disabled(isHealthKitAvailable == false)
        }
        .padding(14)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(AppTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
    }
}

#if DEBUG
    #Preview {
        HealthKitAutoSyncCardComponent(
            isAutoSyncEnabled: .constant(true),
            isHealthKitAvailable: true
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
