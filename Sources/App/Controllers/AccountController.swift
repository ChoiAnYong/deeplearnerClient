//
//  AccountController.swift
//  DeepLearningProject
//
//  Created by 최안용 on 12/16/24.
//

import Vapor
import AWSDynamoDB

struct TransferRequest: Content {
    let fromUserId: String
    let toUserId: String
    let amount: Double
}

struct AccountController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let accounts = routes.grouped("accounts")
        // JWT 인증 미들웨어 적용
        let protected = accounts.grouped(JWTMiddleware())
        
        protected.get(":userId", use: getBalance) // 잔액 확인
        protected.post("transfer", use: transfer)   // 송금
    }
    
    // 잔액 확인
    func getBalance(req: Request) async throws -> MyResponse {
        guard let userId = req.parameters.get("userId") else {
            throw Abort(.badRequest, reason: "userId is missing.")
        }
        
        let dynamoDB = req.application.dynamoDB
        
        let getItemInput = GetItemInput(
            key: ["userId": .s(userId)],
            tableName: "Users"
        )
        
        do {
            let result = try await dynamoDB.getItem(input: getItemInput)
            guard let item = result.item,
                  let balanceAttribute = item["balance"],
                  case let .n(balance) = balanceAttribute else {
                throw Abort(.notFound, reason: "Account not found.")
            }
            return MyResponse(result: balance)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to fetch balance: \(error)")
        }
    }
    
    // 송금 기능
    func transfer(req: Request) async throws -> MyResponse {
        let transferData = try req.content.decode(TransferRequest.self)
        let dynamoDB = req.application.dynamoDB
        
        do {
            // 출금 계정에서 금액 차감
            try await updateBalance(
                dynamoDB: dynamoDB,
                userId: transferData.fromUserId,
                amount: -transferData.amount
            )
            
            // 입금 계정에 금액 추가
            try await updateBalance(
                dynamoDB: dynamoDB,
                userId: transferData.toUserId,
                amount: transferData.amount
            )
            
            return MyResponse(result: "성공")
        } catch {
            throw Abort(.conflict, reason: "Failed to process transfer: \(error)")
        }
    }
    
    // DynamoDB 잔액 업데이트 함수
    private func updateBalance(dynamoDB: DynamoDBClient, userId: String, amount: Double) async throws {
        let updateItemInput = UpdateItemInput(
            conditionExpression: "attribute_exists(userId)", // 계정 존재 확인
            expressionAttributeNames: ["#B": "balance"],
            expressionAttributeValues: [":amount": .n("\(amount)")],
            key: ["userId": .s(userId)],
            tableName: "Users",
            updateExpression: "SET #B = #B + :amount"
        )
        
        do {
            try await dynamoDB.updateItem(input: updateItemInput)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to update balance for \(userId): \(error)")
        }
    }
}
