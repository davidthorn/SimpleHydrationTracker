//
//  UnitsSettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct UnitsSettingsView: View {
    internal var body: some View {
        Text("Units Settings")
            .navigationTitle("Units")
    }
}

#if DEBUG
    #Preview {
        UnitsSettingsView()
    }
#endif
