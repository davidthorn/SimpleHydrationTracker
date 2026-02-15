//
//  DataManagementView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct DataManagementView: View {
    internal var body: some View {
        Text("Data Management")
            .navigationTitle("Data")
    }
}

#if DEBUG
    #Preview {
        DataManagementView()
    }
#endif
