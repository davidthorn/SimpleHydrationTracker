//
//  TodayView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import SwiftUI

internal struct TodayView: View {
    internal var body: some View {
        List {
            NavigationLink(value: TodayRoute.addCustomAmount) {
                Text("Add Custom Amount")
            }
            NavigationLink(value: TodayRoute.editTodayEntry(entryID: UUID())) {
                Text("Edit Today Entry")
            }
            NavigationLink(value: TodayRoute.dayDetail(date: Date())) {
                Text("Day Detail")
            }
            NavigationLink(value: TodayRoute.goalSetup) {
                Text("Goal Setup")
            }
        }
        .navigationTitle("Today")
    }
}

#if DEBUG
    #Preview {
        TodayView()
    }
#endif
