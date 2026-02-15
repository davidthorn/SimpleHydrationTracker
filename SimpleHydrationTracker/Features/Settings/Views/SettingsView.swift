//
//  SettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct SettingsView: View {
    internal var body: some View {
        Text("Settings")
            .navigationTitle("Settings")
    }
}

#if DEBUG
    #Preview {
        SettingsView()
    }
#endif
