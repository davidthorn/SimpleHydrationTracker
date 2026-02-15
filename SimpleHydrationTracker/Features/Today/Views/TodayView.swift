//
//  TodayView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct TodayView: View {
    internal var body: some View {
        Text("Today")
            .navigationTitle("Today")
    }
}

#if DEBUG
    #Preview {
        TodayView()
    }
#endif
