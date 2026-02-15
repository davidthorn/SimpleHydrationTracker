//
//  HydrationDebugBootstrapServiceProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

#if DEBUG
    import Foundation

    internal protocol HydrationDebugBootstrapServiceProtocol: Sendable {
        func bootstrapIfNeeded() async throws
    }
#endif
