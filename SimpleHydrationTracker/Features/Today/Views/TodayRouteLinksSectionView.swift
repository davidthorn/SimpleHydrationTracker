//
//  TodayRouteLinksSectionView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Models
import SwiftUI

internal struct TodayRouteLinksSectionView: View {
    internal init() {}

    internal var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("More")
                .font(.headline)

            NavigationLink(value: TodayRoute.addCustomAmount) {
                TodayRouteRowComponent(title: "Add Custom Amount", systemImage: "plus.circle")
            }

            NavigationLink(
                value: TodayRoute.editTodayEntry(entryID: HydrationEntryIdentifier(value: UUID()))
            ) {
                TodayRouteRowComponent(title: "Edit Today Entry", systemImage: "pencil")
            }

            NavigationLink(
                value: TodayRoute.dayDetail(dayID: HydrationDayIdentifier(value: Date()))
            ) {
                TodayRouteRowComponent(title: "Day Detail", systemImage: "calendar")
            }

            NavigationLink(value: TodayRoute.goalSetup) {
                TodayRouteRowComponent(title: "Goal Setup", systemImage: "target")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            TodayRouteLinksSectionView()
                .padding()
        }
    }
#endif
