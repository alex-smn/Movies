//
//  MoviesListClient.swift
//  Movies
//
//  Created by Alexander Livshits on 15/03/2024.
//

import ComposableArchitecture
import Foundation

// MARK: - API client interface

@DependencyClient
struct FavoritesListClient {
    var fetchMovies: @Sendable (_ page: Int, _ accountId: Int) async throws -> MoviesList
    var fetchSeries: @Sendable (_ page: Int, _ accountId: Int) async throws -> SeriesList
    var requestToken: @Sendable () async throws -> RequestToken
    var authenticate: @Sendable (_ token: String) async throws -> Bool
    var createSessionId: @Sendable (_ token: String) async throws -> Session
    var getAccountDetails: @Sendable (_ sessionId: String) async throws -> Account
}

extension FavoritesListClient: TestDependencyKey {
    static let previewValue = Self(
        fetchMovies: { _, _ in
            .mockFavorites
        },
        fetchSeries: { _, _ in
            .mockFavorites
        },
        requestToken: {
            .mock
        },
        authenticate: { _ in
            true
        },
        createSessionId: { _ in
            .mock
        },
        getAccountDetails: { _ in
            .mock
        }
    )
    
    static let testValue = Self()
}

extension FavoritesListClient: DependencyKey {
    static let liveValue = Self(
        fetchMovies: { page, accountId in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiFavoritesUrlFormat)\(accountId)/favorite/movies?page=\(page)")!, responseType: MoviesList.self)
        },
        fetchSeries: { page, accountId in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiFavoritesUrlFormat)\(accountId)/favorite/tv?page=\(page)")!, responseType: SeriesList.self)
        },
        requestToken: {
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiRequestTokenUrl)")!, responseType: RequestToken.self)
        },
        authenticate: { token in
            let loginSession = LoginSession()
            return await loginSession.signIn(token: token)
        },
        createSessionId: { token in
            let parameters = ["request_token": token]
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiCreateSessionIDUrl)")!, requestType: "POST", parameters: parameters, responseType: Session.self)
        },
        getAccountDetails: { sessionId in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiAccountDetailsUrl)?session_id=\(sessionId)")!, responseType: Account.self)
        }
    )
}

extension DependencyValues {
    var favoritesListClient: FavoritesListClient {
        get { self[FavoritesListClient.self] }
        set { self[FavoritesListClient.self] = newValue }
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

// MARK: - Mock data

extension MoviesList {
    static let mockFavorites = MoviesList(
        page: 1,
        results: [MoviesListItem.mock(id: 1), MoviesListItem.mock(id: 2)],
        totalPages: 1
    )
}

extension SeriesList {
    static let mockFavorites = SeriesList(
        page: 1,
        results: [SeriesListItem.mock(id: 1), SeriesListItem.mock(id: 2)],
        totalPages: 1
    )
}

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
