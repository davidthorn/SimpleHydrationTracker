//
//  LaunchErrorView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct LaunchErrorView: View {
    internal let message: String

    internal var body: some View {
        ContentUnavailableView(
            "Unable to Load Data",
            systemImage: "exclamationmark.triangle.fill",
            description: Text(message)
        )
    }
}

#if DEBUG
    #Preview {
        LaunchErrorView(message: "Please restart the app.")
    }
#endif
