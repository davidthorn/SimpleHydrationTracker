//
//  EditTodayEntryView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI

internal struct EditTodayEntryView: View {
    internal let entryID: HydrationEntryIdentifier

    internal var body: some View {
        Text("Edit Entry")
            .navigationTitle("Edit Entry")
    }
}

#if DEBUG
    #Preview {
        EditTodayEntryView(entryID: HydrationEntryIdentifier(value: UUID()))
    }
#endif
