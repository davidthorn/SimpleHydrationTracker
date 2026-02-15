//
//  StoreFilePathResolving.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal protocol StoreFilePathResolving: Sendable {
    func documentsDirectoryURL() throws -> URL
    func fileURL(fileName: String) throws -> URL
}
