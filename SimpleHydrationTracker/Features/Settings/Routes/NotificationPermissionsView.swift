//
//  NotificationPermissionsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct NotificationPermissionsView: View {
    internal var body: some View {
        Text("Notification Permissions")
            .navigationTitle("Permissions")
    }
}

#if DEBUG
    #Preview {
        NotificationPermissionsView()
    }
#endif
