//
//  HistoryFilterView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct HistoryFilterView: View {
    internal var body: some View {
        Text("History Filter")
            .navigationTitle("Filter")
    }
}

#if DEBUG
    #Preview {
        HistoryFilterView()
    }
#endif
