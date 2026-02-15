//
//  HistoryScene.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct HistoryScene: View {
    internal var body: some View {
        NavigationStack {
            HistoryView()
                .navigationDestination(for: HistoryRoute.self) { route in
                    switch route {
                    case .dayDetail(let date):
                        HistoryDayDetailView(date: date)
                    case .entryDetail(let entryID):
                        EntryDetailView(entryID: entryID)
                    case .historyFilter:
                        HistoryFilterView()
                    }
                }
        }
    }
}

#if DEBUG
    #Preview {
        HistoryScene()
    }
#endif
