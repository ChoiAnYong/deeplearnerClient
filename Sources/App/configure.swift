import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import AWSDynamoDB

public func configure(_ app: Application) throws {
    // AWS DynamoDB 클라이언트 설정
    let dynamoDB = try DynamoDBClient(region: "ap-northeast-2")
    app.storage[Key.self] = dynamoDB
    
    app.http.server.configuration.port = 8080
    // 라우트 등록
    try routes(app)
}

// Storage Key for DynamoDB
private struct Key: StorageKey {
    typealias Value = DynamoDBClient
}

extension Application {
    var dynamoDB: DynamoDBClient {
        guard let db = storage[Key.self] else {
            fatalError("DynamoDB not configured. Use app.dynamoDB to configure.")
        }
        return db
    }
}
