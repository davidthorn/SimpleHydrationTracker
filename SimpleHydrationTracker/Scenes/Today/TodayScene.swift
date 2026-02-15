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
                        AddCustomAmountView(serviceContainer: serviceContainer)
                    case .editTodayEntry(let entryID):
                        EditTodayEntryView(entryID: entryID, serviceContainer: serviceContainer)
                    case .dayDetail(let dayID):
                        DayDetailView(dayID: dayID, serviceContainer: serviceContainer)
                    case .goalSetup:
                        GoalSetupView(serviceContainer: serviceContainer)
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
