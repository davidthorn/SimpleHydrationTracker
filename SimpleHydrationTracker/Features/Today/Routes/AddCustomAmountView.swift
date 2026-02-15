//
//  AddCustomAmountView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI

internal struct AddCustomAmountView: View {
    internal var body: some View {
        Text("Add Custom Amount")
            .navigationTitle("Add Amount")
    }
}

#if DEBUG
    #Preview {
        AddCustomAmountView()
    }
#endif
