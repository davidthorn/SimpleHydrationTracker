//
//  LaunchLoadingView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct LaunchLoadingView: View {
    internal var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading hydration data...")
        }
        .padding()
    }
}

#if DEBUG
    #Preview {
        LaunchLoadingView()
    }
#endif
