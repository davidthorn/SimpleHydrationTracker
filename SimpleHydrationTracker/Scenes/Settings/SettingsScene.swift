//
//  SettingsScene.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct SettingsScene: View {
    internal var body: some View {
        NavigationStack {
            SettingsView()
        }
    }
}

#if DEBUG
    #Preview {
        SettingsScene()
    }
#endif
