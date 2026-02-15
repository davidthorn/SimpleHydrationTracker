//
//  TodayRouteRowComponent.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct TodayRouteRowComponent: View {
    private let title: String
    private let systemImage: String

    internal init(title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
    }

    internal var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#if DEBUG
    #Preview {
        TodayRouteRowComponent(title: "Add Custom Amount", systemImage: "plus.circle")
            .padding()
    }
#endif
