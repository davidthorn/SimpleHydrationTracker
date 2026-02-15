//
//  AppLaunchState.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal enum AppLaunchState: Equatable {
    case loading
    case ready
    case failed(message: String)
}
