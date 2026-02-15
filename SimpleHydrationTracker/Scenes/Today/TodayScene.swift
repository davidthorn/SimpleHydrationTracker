//
//  TodayScene.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct TodayScene: View {
    private let serviceContainer: ServiceContainerProtocol

    internal init(serviceContainer: ServiceContainerProtocol) {
        self.serviceContainer = serviceContainer
    }

    internal var body: some View {
        NavigationStack {
            TodayView(serviceContainer: serviceContainer)
                .navigationDestination(for: TodayRoute.self) { route in
                    switch route {
                    case .addCustomAmount:
                        AddCustomAmountView()
                    case .editTodayEntry(let entryID):
                        EditTodayEntryView(entryID: entryID)
                    case .dayDetail(let dayID):
                        DayDetailView(dayID: dayID)
                    case .goalSetup:
                        GoalSetupView()
                    }
                }
        }
    }
}

#if DEBUG
    #Preview {
        TodayScene(serviceContainer: PreviewServiceContainer())
    }
#endif
