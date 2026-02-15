//
//  EditTodayEntryView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import SwiftUI

internal struct EditTodayEntryView: View {
    internal let entryID: UUID

    internal var body: some View {
        Text("Edit Entry")
            .navigationTitle("Edit Entry")
    }
}

#if DEBUG
    #Preview {
        EditTodayEntryView(entryID: UUID())
    }
#endif
