//
//  GoalSettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct GoalSettingsView: View {
    internal var body: some View {
        Text("Goal Settings")
            .navigationTitle("Goal")
    }
}

#if DEBUG
    #Preview {
        GoalSettingsView()
    }
#endif
