//
//  HistoryDayDetailView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import SwiftUI

internal struct HistoryDayDetailView: View {
    internal let date: Date

    internal var body: some View {
        Text("Day Detail")
            .navigationTitle("Day Detail")
    }
}

#if DEBUG
    #Preview {
        HistoryDayDetailView(date: Date())
    }
#endif
