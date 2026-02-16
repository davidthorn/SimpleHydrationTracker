//
//  HealthKitPermissionStatePillComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 16.02.2026.
//

import Models
import SwiftUI

internal struct HealthKitPermissionStatePillComponent: View {
    private let title: String
    private let state: HealthKitAuthorizationState

    internal init(title: String, state: HealthKitAuthorizationState) {
        self.title = title
        self.state = state
    }

    internal var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppTheme.muted)
            Text(state.displayText)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint(for: state))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule(style: .continuous)
                        .fill(tint(for: state).opacity(0.14))
                )
        }
    }

    private func tint(for state: HealthKitAuthorizationState) -> Color {
        switch state {
        case .authorized:
            return AppTheme.success
        case .denied:
            return AppTheme.error
        case .notDetermined:
            return AppTheme.warning
        case .unavailable:
            return AppTheme.muted
        @unknown default:
            return AppTheme.muted
        }
    }
}

#if DEBUG
    #Preview {
        HStack {
            HealthKitPermissionStatePillComponent(title: "Read", state: .authorized)
            HealthKitPermissionStatePillComponent(title: "Write", state: .denied)
        }
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
