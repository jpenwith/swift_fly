import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let filesDirectoryURL = Environment.get("FILES_DIRECTORY").flatMap { URL(filePath: $0, directoryHint: .isDirectory) }
    let imageController = ImageController(directoryManager: try .init(application: app, filesDirectoryURL: filesDirectoryURL))
    try app.grouped("image").register(collection: imageController)
}
