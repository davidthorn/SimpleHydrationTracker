//
//  ReminderSettingsView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation
import SwiftUI
import SimpleFramework

internal struct ReminderSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ReminderSettingsViewModel
    @State private var showDeleteConfirmation: Bool
    @State private var isSaving: Bool
    @State private var isDeleting: Bool

    internal init(serviceContainer: ServiceContainerProtocol) {
        let vm = ReminderSettingsViewModel(reminderService: serviceContainer.reminderService)
        _viewModel = StateObject(wrappedValue: vm)
        _showDeleteConfirmation = State(initialValue: false)
        _isSaving = State(initialValue: false)
        _isDeleting = State(initialValue: false)
    }

    internal var body: some View {
        ZStack {
            AppTheme.pageGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    SimpleHeroCard(
                        title: "Reminder Schedule",
                        message: "Choose reminder windows and cadence for hydration nudges.",
                        systemImage: "bell.badge",
                        tint: AppTheme.accent
                    )

                    permissionCard
                    scheduleCard

                    if let errorMessage = viewModel.errorMessage {
                        SimpleFormErrorCard(message: errorMessage, tint: AppTheme.error)
                    }

                    SimpleFormActionButtons(
                        showSave: viewModel.canSave,
                        showReset: viewModel.canReset,
                        showDelete: viewModel.canDelete,
                        saveTitle: "Save Schedule",
                        deleteTitle: "Delete Schedule",
                        onSave: {
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                isSaving = true
                                defer { isSaving = false }
                                do {
                                    try await viewModel.save()
                                } catch {
                                    guard Task.isCancelled == false else {
                                        return
                                    }
                                    viewModel.setError("Unable to save reminder settings.")
                                }
                            }
                        },
                        onReset: {
                            viewModel.reset()
                        },
                        onDelete: {
                            showDeleteConfirmation = true
                        }
                    )
                    .opacity((isSaving || isDeleting || viewModel.isLoading) ? 0.6 : 1)
                    .allowsHitTesting(isSaving == false && isDeleting == false && viewModel.isLoading == false)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Reminders")
        .tint(AppTheme.accent)
        .overlay {
            if showDeleteConfirmation {
                ZStack {
                    Color.black.opacity(0.16)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if isDeleting {
                                return
                            }
                            showDeleteConfirmation = false
                        }

                    SimpleDestructiveConfirmationCard(
                        title: "Delete this reminder schedule?",
                        message: "This permanently removes your current reminder cadence.",
                        confirmTitle: "Delete Schedule",
                        tint: AppTheme.error,
                        isDisabled: isDeleting,
                        onCancel: {
                            showDeleteConfirmation = false
                        },
                        onConfirm: {
                            Task {
                                guard Task.isCancelled == false else {
                                    return
                                }
                                isDeleting = true
                                defer { isDeleting = false }
                                do {
                                    try await viewModel.delete()
                                    guard Task.isCancelled == false else {
                                        return
                                    }
                                    dismiss()
                                } catch {
                                    guard Task.isCancelled == false else {
                                        return
                                    }
                                    viewModel.setError("Unable to delete reminder schedule.")
                                    showDeleteConfirmation = false
                                }
                            }
                        }
                    )
                    .padding(.horizontal, 16)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.start()
            await viewModel.refreshPermissionStatus()
        }
        .animation(.easeInOut(duration: 0.2), value: showDeleteConfirmation)
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading reminders...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    @ViewBuilder
    private var permissionCard: some View {
        switch viewModel.authorizationStatus {
        case .authorized, .provisional:
            SimpleStatusCard(
                title: "Notifications Enabled",
                message: "Reminder alerts can be delivered on this device.",
                systemImage: "checkmark.seal.fill",
                tint: AppTheme.success
            )
        case .notDetermined:
            SimpleStatusCard(
                title: "Permission Required",
                message: "Request notification permission from the Permissions route.",
                systemImage: "bell.badge",
                tint: AppTheme.warning
            )
        case .denied:
            SimpleStatusCard(
                title: "Permission Denied",
                message: "Enable notification access in Permissions to use reminders.",
                systemImage: "bell.slash.fill",
                tint: AppTheme.error
            )
        }
    }

    private var scheduleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            fieldTitle("Schedule")

            SimpleToggleCardRow(
                isOn: $viewModel.isEnabled,
                title: "Enable Reminders",
                message: "Allow scheduled hydration nudges.",
                systemImage: "bell.badge.fill",
                tint: AppTheme.accent,
                isEnabled: viewModel.isLoading == false && isSaving == false && isDeleting == false
            )

            if viewModel.isEnabled {
                Picker("Start", selection: $viewModel.startHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(String(format: "%02d:00", hour)).tag(hour)
                    }
                }
                .disabled(viewModel.isLoading || isSaving || isDeleting)

                Picker("End", selection: $viewModel.endHour) {
                    ForEach(1..<24, id: \.self) { hour in
                        Text(String(format: "%02d:00", hour)).tag(hour)
                    }
                }
                .disabled(viewModel.isLoading || isSaving || isDeleting)

                Picker("Interval", selection: $viewModel.intervalMinutes) {
                    Text("30 min").tag(30)
                    Text("60 min").tag(60)
                    Text("90 min").tag(90)
                    Text("120 min").tag(120)
                    Text("180 min").tag(180)
                }
                .disabled(viewModel.isLoading || isSaving || isDeleting)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.muted.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func fieldTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .foregroundStyle(AppTheme.muted)
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            ReminderSettingsView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
