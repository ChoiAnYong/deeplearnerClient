//
//  AuthController.swift
//  DeepLearningProject
//
//  Created by 최안용 on 12/16/24.
//


import Vapor
import JWTKit
import AWSDynamoDB

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("login", use: login) // 로그인 엔드포인트
    }

    // 로그인 로직
    func login(req: Request) async throws -> MyResponse {
        let loginData = try req.content.decode(LoginRequest.self)
        let dynamoDB = req.application.dynamoDB

        // DynamoDB에서 사용자 조회
        let getItemInput = GetItemInput(
            key: ["userId": .s(loginData.userId)],
            tableName: "Users"
        )
            
        do {
            // 사용자 데이터 조회
            let result = try await dynamoDB.getItem(input: getItemInput)
            guard let item = result.item,
                  let passwordAttribute = item["password"],
                  let balanceAttribute = item["balance"],
                  case let .s(storedPassword) = passwordAttribute,
                  case let .n(balanceAttribute) = balanceAttribute,
                  let accounts = Double(balanceAttribute) else {
                throw Abort(.unauthorized, reason: "Invalid userId or password.")
            }

            // 비밀번호 확인
            guard loginData.password == storedPassword else {
                throw Abort(.unauthorized, reason: "Invalid userId or password.")
            }

            // JWT 토큰 생성
            let user = User(id: UUID().uuidString, userId: loginData.userId, password: storedPassword)
            let token = try JWTService.createToken(user: user)

            // 토큰 반환
            
//            return Response(status: .ok, body: .init(string:"result: \(token)"))
            return MyResponse(result: token)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to fetch user data from DynamoDB: \(error)")
        }
    }
}
