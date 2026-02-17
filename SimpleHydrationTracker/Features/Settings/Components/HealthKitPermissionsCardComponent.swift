//
//  HealthKitPermissionsCardComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 16.02.2026.
//

import SimpleFramework
import SwiftUI

internal struct HealthKitPermissionsCardComponent: View {
    private let permissionState: HealthKitPermissionState
    private let statusSummaryText: String
    private let isHealthKitAvailable: Bool
    private let onRequestAccess: () -> Void
    private let onOpenSettings: () -> Void

    internal init(
        permissionState: HealthKitPermissionState,
        statusSummaryText: String,
        isHealthKitAvailable: Bool,
        onRequestAccess: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.permissionState = permissionState
        self.statusSummaryText = statusSummaryText
        self.isHealthKitAvailable = isHealthKitAvailable
        self.onRequestAccess = onRequestAccess
        self.onOpenSettings = onOpenSettings
    }

    internal var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lock.shield")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.warning)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(AppTheme.warning.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Permissions")
                        .font(.subheadline.weight(.semibold))
                    Text(statusSummaryText)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                HealthKitPermissionStatePillComponent(title: "Read", state: permissionState.read)
                HealthKitPermissionStatePillComponent(title: "Write", state: permissionState.write)
                Spacer()
            }

            if isHealthKitAvailable {
                HStack(spacing: 10) {
                    Button("Request Access") {
                        onRequestAccess()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Open Settings") {
                        onOpenSettings()
                    }
                    .buttonStyle(.bordered)
                }
            }
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
        HealthKitPermissionsCardComponent(
            permissionState: HealthKitPermissionState(read: .authorized, write: .denied),
            statusSummaryText: "Read is authorized, write is denied.",
            isHealthKitAvailable: true,
            onRequestAccess: {},
            onOpenSettings: {}
        )
        .padding()
        .background(AppTheme.pageGradient)
    }
#endif
