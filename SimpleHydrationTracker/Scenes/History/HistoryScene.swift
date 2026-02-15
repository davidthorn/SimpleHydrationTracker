//
//  HistoryScene.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct HistoryScene: View {
    private let serviceContainer: ServiceContainerProtocol

    internal init(serviceContainer: ServiceContainerProtocol) {
        self.serviceContainer = serviceContainer
    }

    internal var body: some View {
        NavigationStack {
            HistoryView(serviceContainer: serviceContainer)
                .navigationDestination(for: HistoryRoute.self) { route in
                    switch route {
                    case .dayDetail(let dayID):
                        HistoryDayDetailView(dayID: dayID, serviceContainer: serviceContainer)
                    case .entryDetail(let entryID):
                        EntryDetailView(entryID: entryID, serviceContainer: serviceContainer)
                    case .historyFilter:
                        HistoryFilterView()
                    }
                }
        }
    }
}

#if DEBUG
    #Preview {
        HistoryScene(serviceContainer: PreviewServiceContainer())
    }
#endif
