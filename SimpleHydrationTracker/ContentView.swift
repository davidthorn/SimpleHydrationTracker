//
//  ContentView.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.26.
//

import SwiftUI

internal struct ContentView: View {
    internal var body: some View {
        TabView {
            TodayScene()
                .tabItem {
                    Label("Today", systemImage: "drop.fill")
                }

            HistoryScene()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }

            SettingsScene()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#if DEBUG
    #Preview {
        ContentView()
    }
#endif
