//
//  HistoryView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct HistoryView: View {
    internal var body: some View {
        Text("History")
            .navigationTitle("History")
    }
}

#if DEBUG
    #Preview {
        HistoryView()
    }
#endif
