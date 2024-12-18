import Fluent
import Vapor


func routes(_ app: Application) throws {
    // 로그인 엔드포인트
    let authController = AuthController()
    try app.register(collection: authController)

    // AccountController는 인증 미들웨어가 적용되므로 인증된 사용자만 접근 가능합니다.
    let accountController = AccountController()
    try app.register(collection: accountController)
}
