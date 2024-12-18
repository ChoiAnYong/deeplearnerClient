//
//  User.swift
//  DeepLearningProject
//
//  Created by 최안용 on 12/17/24.
//


import Vapor
import JWTKit

struct User: Content {
    let id: String
    let userId: String
    let password: String // 암호화된 비밀번호로 처리해야 합니다.
}

struct LoginRequest: Content {
    let userId: String
    let password: String
}

struct JWTUser: Content, Authenticatable, JWTPayload {
    let sub: String
    let exp: ExpirationClaim

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
