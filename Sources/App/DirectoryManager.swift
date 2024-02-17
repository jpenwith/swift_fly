//
//  DirectoryManager
//
//
//  Created by me on 15/02/2024.
//

import Foundation
import Vapor


struct DirectoryManager {
    let application: Application
    let filesDirectoryURL: URL?
    
    init(application: Application, filesDirectoryURL: URL?) throws {
        self.application = application
        self.filesDirectoryURL = filesDirectoryURL
        
        let fileManager = FileManager.default
        
        if Environment.get("CLEAR_CACHE") == "true" {
            try? fileManager.removeItem(at: cacheDirectoryURL)
        }
        try [imagesInputCacheDirectoryURL, videosInputCacheDirectoryURL, imagesOutputCacheDirectoryURL, videosOutputCacheDirectoryURL].forEach {
            try fileManager.createDirectory(at: $0, withIntermediateDirectories: true)
        }
    }
}

extension DirectoryManager {
    var imagesInputCacheDirectoryURL: URL {
        inputCacheDirectoryURL
            .appendingPathComponent("images", conformingTo: .directory)
    }
    
    var videosInputCacheDirectoryURL: URL {
        inputCacheDirectoryURL
            .appendingPathComponent("videos", conformingTo: .directory)
    }
    
    var imagesOutputCacheDirectoryURL: URL {
        outputCacheDirectoryURL
            .appendingPathComponent("images", conformingTo: .directory)
    }
    
    var videosOutputCacheDirectoryURL: URL {
        outputCacheDirectoryURL
            .appendingPathComponent("videos", conformingTo: .directory)
    }
}

extension DirectoryManager {
    private var inputCacheDirectoryURL: URL {
        cacheDirectoryURL
            .appendingPathComponent("input", conformingTo: .directory)
    }
    
    private var outputCacheDirectoryURL: URL {
        cacheDirectoryURL
            .appendingPathComponent("output", conformingTo: .directory)
    }

    private var cacheDirectoryURL: URL {
        workingDirectoryURL
            .appendingPathComponent("cache", conformingTo: .directory)
    }

    private var workingDirectoryURL: URL {
        URL(filePath: application.directory.workingDirectory, directoryHint: .isDirectory)
    }
}
