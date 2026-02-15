//
//  ServiceContainerProtocol.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal protocol ServiceContainerProtocol: Sendable {
    var hydrationStore: HydrationStoreProtocol { get }
    var goalStore: GoalStoreProtocol { get }
}
