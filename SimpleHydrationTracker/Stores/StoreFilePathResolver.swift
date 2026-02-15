//
//  StoreFilePathResolver.swift
//  SimpleHydrationTracker
//
//  Created by David Thorn on 15.02.2026.
//

import Foundation

internal struct StoreFilePathResolver {
    private let fileManager: FileManager

    internal init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    internal func documentsDirectoryURL() throws -> URL {
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw StoreInfrastructureError.documentsDirectoryUnavailable
        }

        return documentsURL
    }

    internal func fileURL(fileName: String) throws -> URL {
        let documentsURL = try documentsDirectoryURL()
        return documentsURL.appendingPathComponent(fileName)
    }
}
