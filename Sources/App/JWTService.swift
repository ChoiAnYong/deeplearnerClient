//
//  JWTService.swift
//  DeepLearningProject
//
//  Created by 최안용 on 12/17/24.
//


import JWTKit

struct JWTService {
    static let secretKey = "your-secret-key" // 실제로는 환경 변수로 관리하는 것이 좋습니다.
    
    static func createToken(user: User) throws -> String {
        let signer = JWTSigner.hs256(key: secretKey)
        
        let expiration = ExpirationClaim(value: Date().addingTimeInterval(3600)) // 1시간 유효
        let payload = JWTUser(sub: user.id, exp: expiration)
        
        return try signer.sign(payload)
    }
    
    static func verifyToken(token: String) throws -> JWTUser {
        let signer = JWTSigner.hs256(key: secretKey)
        return try signer.verify(token, as: JWTUser.self)
    }
}