//
//  GoalSetupView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct GoalSetupView: View {
    internal var body: some View {
        Text("Goal Setup")
            .navigationTitle("Goal Setup")
    }
}

#if DEBUG
    #Preview {
        GoalSetupView()
    }
#endif
