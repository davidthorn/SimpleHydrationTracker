//
//  HistoryScene.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct HistoryScene: View {
    internal var body: some View {
        NavigationStack {
            HistoryView()
        }
    }
}

#if DEBUG
    #Preview {
        HistoryScene()
    }
#endif
