//
//  AuthorizationManager.swift
//  Movies
//
//  Created by Alexander Livshits on 19/03/2024.
//

import Foundation

class AuthorizationManager {
    static func getSessionInfo() -> (String, Int)? {
        if let sessionId = KeychainHelper.read(service: "", account: "accountId"),
           let accountIdString = KeychainHelper.read(service: "", account: "accountId"),
           let accountId = Int(accountIdString)
        {
            return (sessionId, accountId)
        }
        return nil
    }
    
    static func authorize() async throws -> (String, Int) {
        if let info = getSessionInfo() {
            return info
        }
        
        let token = try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiRequestTokenUrl)")!, responseType: RequestToken.self)
        let loginSession = LoginSession()
        _ = await loginSession.signIn(token: token.requestToken)
        let parameters = ["request_token": token.requestToken]
        let session = try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiCreateSessionIDUrl)")!, requestType: "POST", parameters: parameters, responseType: Session.self)
        let accountDetails = try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiAccountUrl)?session_id=\(session.sessionId)")!, responseType: Account.self)
        
        _ = KeychainHelper.save(account: "sessionId", service: "", value: session.sessionId)
        _ = KeychainHelper.save(account: "accountId", service: "", value: "\(accountDetails.id)")
        return (session.sessionId, accountDetails.id)
    }
    
    static func logOut() {
        KeychainHelper.clear()
    }
}

// MARK: - API Models

struct RequestToken: Codable, Equatable {
    let success: Bool
    let expiresAt: String
    let requestToken: String
}

struct Session: Codable, Equatable {
    let success: Bool
    let sessionId: String
}

struct Account: Codable, Equatable {
    let id: Int
    let iso6391: String
    let name: String
    let includeAdult: Bool
    let username: String
}

struct AccountState: Codable, Equatable {
    let id: Int
    let favorite: Bool
}

struct ToggleFavoritesResponse: Codable, Equatable {
    let success: Bool
    let statusMessage: String
}
// MARK: - Mock data

extension RequestToken {
    static let mock = RequestToken(
        success: true,
        expiresAt: "2024-03-17 17:02:24 UTC",
        requestToken: "5af3e1ffc58020046c43dfde7103f35cb65462e8"
    )
}

extension Session {
    static let mock = Session(
        success: true,
        sessionId: "72fb9e2473618a5dde3b264f7cc1a1a24cc7f75c"
    )
}

extension Account {
    static let mock = Account(
        id: 123,
        iso6391: "en",
        name: "name",
        includeAdult: false,
        username: "username"
    )
}

extension AccountState {
    static func mock() -> AccountState {
        AccountState(id: 1, favorite: true)
    }
}

extension ToggleFavoritesResponse {
    static func mock() -> ToggleFavoritesResponse {
        ToggleFavoritesResponse(success: true, statusMessage: "Success")
    }
}
