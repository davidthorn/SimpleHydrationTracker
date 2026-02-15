//
//  HistoryView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI

internal struct HistoryView: View {
    internal var body: some View {
        List {
            NavigationLink(
                value: HistoryRoute.dayDetail(dayID: HydrationDayIdentifier(value: Date()))
            ) {
                Text("Day Detail")
            }
            NavigationLink(
                value: HistoryRoute.entryDetail(entryID: HydrationEntryIdentifier(value: UUID()))
            ) {
                Text("Entry Detail")
            }
            NavigationLink(value: HistoryRoute.historyFilter) {
                Text("History Filter")
            }
        }
        .navigationTitle("History")
    }
}

#if DEBUG
    #Preview {
        HistoryView()
    }
#endif
