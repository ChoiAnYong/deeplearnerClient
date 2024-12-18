//
//  JWTMiddleware.swift
//  DeepLearningProject
//
//  Created by 최안용 on 12/17/24.
//


import Vapor
import JWTKit

struct JWTMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        // Authorization 헤더에서 토큰 추출
        guard let authHeader = request.headers.bearerAuthorization else {
            let response = Response(status: .unauthorized)
            response.body = .init(string: "Missing authorization token")
            return request.eventLoop.future(response)
        }

        do {
            // JWT 토큰 검증
            let user = try JWTService.verifyToken(token: authHeader.token)
            request.auth.login(user)
        } catch {
            let response = Response(status: .unauthorized)
            response.body = .init(string: "Invalid or expired token")
            return request.eventLoop.future(response)
        }

        return next.respond(to: request)
    }
}
