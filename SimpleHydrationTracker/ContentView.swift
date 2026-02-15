//
//  ContentView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.26.
//

import SwiftUI

internal struct ContentView: View {
    private let serviceContainer: ServiceContainerProtocol

    internal init(serviceContainer: ServiceContainerProtocol) {
        self.serviceContainer = serviceContainer
    }

    internal var body: some View {
        TabView {
            TodayScene(serviceContainer: serviceContainer)
                .tabItem {
                    Label("Today", systemImage: "drop.fill")
                }

            HistoryScene(serviceContainer: serviceContainer)
                .tabItem {
                    Label("History", systemImage: "calendar")
                }

            SettingsScene(serviceContainer: serviceContainer)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#if DEBUG
    #Preview {
        ContentView(serviceContainer: PreviewServiceContainer())
    }
#endif
