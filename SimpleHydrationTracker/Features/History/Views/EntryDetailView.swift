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
    internal let serviceContainer: ServiceContainerProtocol

    internal init(entryID: HydrationEntryIdentifier, serviceContainer: ServiceContainerProtocol) {
        self.entryID = entryID
        self.serviceContainer = serviceContainer
    }

    internal var body: some View {
        EditTodayEntryView(entryID: entryID, serviceContainer: serviceContainer)
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            EntryDetailView(
                entryID: HydrationEntryIdentifier(value: UUID()),
                serviceContainer: PreviewServiceContainer()
            )
        }
    }
#endif
