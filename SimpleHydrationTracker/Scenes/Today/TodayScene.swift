//
//  TodayScene.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct TodayScene: View {
    internal var body: some View {
        NavigationStack {
            TodayView()
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
        TodayScene()
    }
#endif
