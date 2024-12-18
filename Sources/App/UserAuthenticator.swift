////
////  UserAuthenticator.swift
////  DeepLearningProject
////
////  Created by 최안용 on 12/16/24.
////
//
//import Vapor
//import JWTKit
//import AWSDynamoDB
//
//struct UserAuthenticator: BearerAuthenticator {
//    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
//        do {
//            // JWT에서 사용자 정보를 추출
//            let payload = try request.jwt.verify(bearer.token, as: UserPayload.self)
//            
//            // DynamoDB에서 사용자 정보 확인
//            let dynamoDB = request.application.dynamoDB
//            let getItemInput = GetItemInput(
//                key: ["userId": .s(payload.userId)], // userId는 String 타입
//                tableName: "Users"
//            )
//            
//            // DynamoDB에서 사용자 정보 조회
//            return dynamoDB.getItem(input: getItemInput).flatMap { result in
//                guard let item = result.item else {
//                    return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "User not found"))
//                }
//                
//                // DynamoDB에서 유저 정보를 성공적으로 찾은 경우, User 객체 생성
//                guard let username = item["username"]?.s, let email = item["email"]?.s else {
//                    return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Invalid user data"))
//                }
//                
//                let user = User(username: username, email: email)
//                
//                // 인증 완료 후 사용자 로그인 처리
//                request.auth.login(user)
//                return request.eventLoop.makeSucceededFuture(())
//            }
//        } catch {
//            return request.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "Invalid or expired token"))
//        }
//    }
//}
