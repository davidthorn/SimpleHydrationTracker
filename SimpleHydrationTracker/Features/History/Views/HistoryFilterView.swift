//
//  HistoryFilterView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import SwiftUI
import Models
import SimpleFramework

internal struct HistoryFilterView: View {
    @StateObject private var viewModel: HistoryFilterViewModel

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = HistoryFilterViewModel(historyFilterPreferenceService: serviceContainer.historyFilterPreferenceService)
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        Form {
            Section {
                SimpleStatusCard(
                    title: "History Filter",
                    message: "Adjust what appears in history to focus on specific data.",
                    systemImage: "line.3.horizontal.decrease.circle",
                    tint: AppTheme.accent
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Time Range") {
                Picker(
                    "Range",
                    selection: Binding(
                        get: { viewModel.selection },
                        set: { selection in
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                await viewModel.updateSelection(selection)
                            }
                        }
                    )
                ) {
                    ForEach(HistoryFilterSelection.allCases) { selection in
                        Text(selection.title).tag(selection)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Sources") {
                Toggle(
                    "Quick Add",
                    isOn: Binding(
                        get: { viewModel.includeQuickAdd },
                        set: { isOn in
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                await viewModel.updateIncludeQuickAdd(isOn)
                            }
                        }
                    )
                )
                Toggle(
                    "Custom Amount",
                    isOn: Binding(
                        get: { viewModel.includeCustomAmount },
                        set: { isOn in
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                await viewModel.updateIncludeCustomAmount(isOn)
                            }
                        }
                    )
                )
                Toggle(
                    "Edited",
                    isOn: Binding(
                        get: { viewModel.includeEdited },
                        set: { isOn in
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                await viewModel.updateIncludeEdited(isOn)
                            }
                        }
                    )
                )
            }

            if viewModel.hasChanges {
                Section {
                    Button("Reset", role: .cancel) {
                        Task {
                            guard Task.isCancelled == false else {
                                return
                            }
                            await viewModel.reset()
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.pageGradient)
        .navigationTitle("Filter")
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.start()
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            HistoryFilterView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
