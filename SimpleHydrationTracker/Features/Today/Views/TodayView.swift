//
//  TodayView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import Models
import SwiftUI
import SimpleFramework

internal struct TodayView: View {
    @StateObject private var viewModel: TodayViewModel
    @State private var quickAddErrorMessage: String?
    @State private var quickAddSuccessMessage: String?

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = TodayViewModel(
            hydrationService: serviceContainer.hydrationService,
            goalService: serviceContainer.goalService,
            unitsPreferenceService: serviceContainer.unitsPreferenceService,
            sipSizePreferenceService: serviceContainer.sipSizePreferenceService,
            healthKitHydrationService: serviceContainer.healthKitHydrationService,
            hydrationEntrySyncMetadataService: serviceContainer.hydrationEntrySyncMetadataService
        )
        _viewModel = StateObject(wrappedValue: vm)
    }

    internal var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    TodayHeroCardComponent(
                        title: "Today at a Glance",
                        message: "Track progress, log quickly, and manage your current day from one flow.",
                        systemImage: "drop.circle.fill",
                        tint: AppTheme.accent
                    )

                    TodayProgressCardView(
                        consumedMilliliters: viewModel.state.consumedMilliliters,
                        goalMilliliters: viewModel.state.goalMilliliters,
                        remainingMilliliters: viewModel.state.remainingMilliliters,
                        progress: viewModel.state.progress,
                        selectedUnit: viewModel.selectedUnit
                    )

                    TodayQuickAddSectionView(
                        quickAddOptions: viewModel.quickAddOptions,
                        selectedUnit: viewModel.selectedUnit
                    ) { amount in
                        Task {
                            guard Task.isCancelled == false else {
                                return
                            }

                            do {
                                try await viewModel.addQuickAmount(amount)
                                guard Task.isCancelled == false else {
                                    return
                                }
                                withAnimation {
                                    quickAddSuccessMessage = "Added \(viewModel.selectedUnit.format(milliliters: amount.milliliters))"
                                }
                            } catch {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                quickAddErrorMessage = "Unable to add hydration right now."
                            }
                        }
                    }

                    TodayIntakeChartCardComponent(
                        chartData: viewModel.intakeChartData,
                        selectedUnit: viewModel.selectedUnit
                    )

                    if let errorMessage = viewModel.state.errorMessage {
                        SimpleStatusCard(
                            title: "Unable to Refresh Today",
                            message: errorMessage,
                            systemImage: "exclamationmark.triangle.fill",
                            tint: AppTheme.error
                        )
                    }

                    TodayRouteLinksSectionView(
                        currentDayID: HydrationDayIdentifier(value: viewModel.state.date),
                        latestEntryID: viewModel.latestEntryID
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Today")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: TodayRoute.addCustomAmount) {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let quickAddSuccessMessage {
                TodayToastComponent(
                    message: quickAddSuccessMessage,
                    systemImage: "checkmark.circle.fill",
                    tint: AppTheme.success
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: quickAddSuccessMessage)
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.start()
        }
        .task(id: quickAddSuccessMessage) {
            guard quickAddSuccessMessage != nil else {
                return
            }

            do {
                try await Task.sleep(nanoseconds: 1_800_000_000)
                guard Task.isCancelled == false else {
                    return
                }
                withAnimation {
                    quickAddSuccessMessage = nil
                }
            } catch {
                guard Task.isCancelled == false else {
                    return
                }
            }
        }
        .alert("Unable to Add Water", isPresented: quickAddErrorAlertBinding) {
            Button("OK", role: .cancel) {
                quickAddErrorMessage = nil
            }
        } message: {
            Text(quickAddErrorMessage ?? "")
        }
    }

    private var quickAddErrorAlertBinding: Binding<Bool> {
        Binding(
            get: { quickAddErrorMessage != nil },
            set: { isPresented in
                if isPresented == false {
                    quickAddErrorMessage = nil
                }
            }
        )
    }
}

#if DEBUG
    #Preview {
        TodayView(serviceContainer: PreviewServiceContainer())
    }
#endif
