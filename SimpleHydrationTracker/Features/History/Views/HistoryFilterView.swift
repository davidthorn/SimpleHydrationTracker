//
//  HistoryFilterView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI
import Models

internal struct HistoryFilterView: View {
    @StateObject private var viewModel: HistoryFilterViewModel

    internal init() {
        let vm = HistoryFilterViewModel()
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        Form {
            Section("Time Range") {
                Picker("Range", selection: $viewModel.selection) {
                    ForEach(HistoryFilterSelection.allCases) { selection in
                        Text(selection.title).tag(selection)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Sources") {
                Toggle("Quick Add", isOn: $viewModel.includeQuickAdd)
                Toggle("Custom Amount", isOn: $viewModel.includeCustomAmount)
                Toggle("Edited", isOn: $viewModel.includeEdited)
            }

            if viewModel.hasChanges {
                Section {
                    Button("Reset", role: .cancel) {
                        viewModel.reset()
                    }
                }
            }
        }
        .navigationTitle("Filter")
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            HistoryFilterView()
        }
    }
#endif
