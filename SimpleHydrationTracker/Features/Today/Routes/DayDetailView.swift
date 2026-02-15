//
//  DayDetailView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI

internal struct DayDetailView: View {
    internal let dayID: HydrationDayIdentifier

    internal var body: some View {
        Text("Day Detail")
            .navigationTitle("Day Detail")
    }
}

#if DEBUG
    #Preview {
        DayDetailView(dayID: HydrationDayIdentifier(value: Date()))
    }
#endif
