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
        Form {
            Section {
                SettingsHeroCardComponent(
                    title: "Reminder Schedule",
                    message: "Choose reminder windows and cadence for hydration nudges.",
                    systemImage: "bell.badge",
                    tint: AppTheme.accent
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Permission") {
                switch viewModel.authorizationStatus {
                case .authorized, .provisional:
                    SettingsStatusCardComponent(
                        title: "Notifications Enabled",
                        message: "Reminder alerts can be delivered on this device.",
                        systemImage: "checkmark.seal.fill",
                        tint: AppTheme.success
                    )
                case .notDetermined:
                    SettingsStatusCardComponent(
                        title: "Permission Required",
                        message: "Request notification permission from the Permissions route.",
                        systemImage: "bell.badge",
                        tint: AppTheme.warning
                    )
                case .denied:
                    SettingsStatusCardComponent(
                        title: "Permission Denied",
                        message: "Enable notification access in Permissions to use reminders.",
                        systemImage: "bell.slash.fill",
                        tint: AppTheme.error
                    )
                }
            }

            Section("Schedule") {
                Toggle("Enable Reminders", isOn: $viewModel.isEnabled)
                    .disabled(viewModel.isLoading || isSaving || isDeleting)

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

            if let errorMessage = viewModel.errorMessage {
                Section {
                    SettingsStatusCardComponent(
                        title: "Reminder Error",
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle.fill",
                        tint: AppTheme.error
                    )
                }
            }

            if viewModel.canReset {
                Section {
                    Button("Reset", role: .cancel) {
                        viewModel.reset()
                    }
                    .disabled(isSaving || isDeleting)
                }
            }

            if viewModel.canDelete {
                Section {
                    Button("Delete Schedule", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .disabled(isDeleting || isSaving)
                }
            }
        }
        .navigationTitle("Reminders")
        .scrollContentBackground(.hidden)
        .background(AppTheme.pageGradient)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.canSave {
                    Button("Save") {
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
                    }
                    .disabled(isSaving || isDeleting)
                }
            }
        }
        .alert("Are you sure you want to delete this?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
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
                    }
                }
            }
        }
        .task {
            guard Task.isCancelled == false else {
                return
            }
            await viewModel.start()
            await viewModel.refreshPermissionStatus()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Loading reminders...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            ReminderSettingsView(serviceContainer: PreviewServiceContainer())
        }
    }
#endif
