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
        }
    }
}

#if DEBUG
    #Preview {
        TodayScene()
    }
#endif
