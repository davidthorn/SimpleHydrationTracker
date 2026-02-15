//
//  EntryDetailView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI

internal struct EntryDetailView: View {
    internal let entryID: HydrationEntryIdentifier

    internal var body: some View {
        Text("Entry Detail")
            .navigationTitle("Entry Detail")
    }
}

#if DEBUG
    #Preview {
        EntryDetailView(entryID: HydrationEntryIdentifier(value: UUID()))
    }
#endif
