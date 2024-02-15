//
//  ImageController.swift
//
//
//  Created by me on 10/02/2024.
//

import ImageIO
import Foundation
import MediaToolSwift
import UniformTypeIdentifiers
import Vapor


struct ImageController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.on(.GET, use: `get`)
    }
}

extension ImageController {
    func get(_ request: Request) async throws -> Response {
        let action = Action(request: request)

        return try await action.response
    }
}

extension ImageController {
    struct Action {
        let request: Request
        
        var response: Response {
            get async throws {
                return try await execute()
            }
        }
        
        private var query: Query {
            get throws {
                try request.query.decode(Query.self)
            }
        }
        
        private func execute() async throws -> Vapor.Response {
            let outputFileURL = try outputFileURL

            if FileManager.default.fileExists(atPath: outputFileURL.path) {
                return request.fileio.streamFile(at: outputFileURL.path)
            }

            let inputFileURL = try inputFileURL

            if !FileManager.default.fileExists(atPath: inputFileURL.path) {
                try await loadInputImage()
            }

            let info = try ImageTool.convert(
                source: inputFileURL,
                destination: outputFileURL,
                settings: .init(
                    format: try query.output.mediaToolFormat,
                    size: try query.output.mediaToolSize,
                    quality: try query.output.quality
                )
            )

            return request.fileio.streamFile(at: outputFileURL.path)
        }
        
    }
}

extension ImageController.Action {
    private func loadInputImage() async throws {
        let imageRequest = ClientRequest(method: .GET, url: try query.input.url, headers: .init())

        let imageResponse = try await request.client.send(imageRequest)
        guard let imageResponseBody = imageResponse.body else {
            throw Abort(.badRequest)
        }

        try await request.fileio.writeFile(imageResponseBody, at: try inputFileURL.path)
    }
    
    private func respondWithOutputImage() async throws -> Response {
        return request.fileio.streamFile(at: try outputFileURL.path)
    }
    
    private var inputFileURL: URL {
        get throws {
            let workingDirectoryURL = URL(filePath: request.application.directory.workingDirectory, directoryHint: .isDirectory)

            let inputFileURL = workingDirectoryURL
                .appendingPathComponent("cache", conformingTo: .directory)
                .appendingPathComponent("input", conformingTo: .directory)
                .appendingPathComponent("images", conformingTo: .directory)
                .appendingPathComponent(try query.input.digestString, conformingTo: try query.input.uti)

            try FileManager.default.createDirectory(at: inputFileURL.deletingLastPathComponent(), withIntermediateDirectories: true)

            return inputFileURL
        }
    }
    
    private var outputFileURL: URL {
        get throws {
            let workingDirectoryURL = URL(filePath: request.application.directory.workingDirectory, directoryHint: .isDirectory)

            let outputFileURL = workingDirectoryURL
                .appendingPathComponent("cache", conformingTo: .directory)
                .appendingPathComponent("output", conformingTo: .directory)
                .appendingPathComponent("images", conformingTo: .directory)
                .appendingPathComponent(try query.digestString, conformingTo: try query.output.uti)
            
            try FileManager.default.createDirectory(at: outputFileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            return outputFileURL
        }
    }

}


extension ImageController.Action {
    struct Query: Content {
        let input: Input
        let output: Output
        
        struct Input: Content {
            let url: URI
            let uti: UTType
            
            var digestString: String {
                let stringToDigest = url.string

                return SHA256.hash(data: stringToDigest.data(using: .utf8)!).compactMap { String(format: "%02x", $0) }.joined()
            }
        }

        struct Output: Content {
            let uti: UTType
            let size: CGSize?
            let aspectMode: AspectMode?
            let quality: Double?
            
            enum AspectMode: String, Content {
                case fit
                case fill
            }
            
            var mediaToolFormat: MediaToolSwift.ImageFormat {
                get throws {
                    switch uti {
                    case .jpeg:
                        return .jpeg
                    case .png:
                        return .png
                    default:
                        throw Abort(.badRequest, reason: "Output UTI: \(uti) not supported")
                    }
                }
            }
            
            var mediaToolSize: MediaToolSwift.ImageSize {
                guard let size = size else {
                    return .original
                }
                
                let aspectMode = aspectMode ?? .fit
                
                switch aspectMode {
                case .fit:
                    return .fit(size)
                case .fill:
                    //TODO, support .fill
                    return .crop(fit: size, options: .init(origin: .zero, size: size))
                }
            }
            
            var digestString: String {
                let stringToDigest = [
                    uti.identifier,
                    size.flatMap { String(describing: $0) } ?? "nil",
                    aspectMode?.rawValue ?? "nil",
                    quality.flatMap { String(describing: $0) } ?? "nil",
                ].joined(separator: "_")

                return SHA256.hash(data: stringToDigest.data(using: .utf8)!).compactMap { String(format: "%02x", $0) }.joined()
            }
        }
        
        var digestString: String {
            let stringToDigest = [
                input.digestString,
                output.digestString
            ].joined(separator: "_")

            return SHA256.hash(data: stringToDigest.data(using: .utf8)!).compactMap { String(format: "%02x", $0) }.joined()
        }

    }
}
