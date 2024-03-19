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
    var authorize: @Sendable () async throws -> (String, Int)
    var getSessionInfo: @Sendable () -> (String, Int)?
    var logOut: @Sendable () -> Void
}

extension FavoritesListClient: TestDependencyKey {
    static let previewValue = Self(
        fetchMovies: { _, _ in
            .mockFavorites
        },
        fetchSeries: { _, _ in
            .mockFavorites
        },
        authorize: {
            ("", 0)
        },
        getSessionInfo: {
            ("", 0)
        },
        logOut: {
            
        }
    )
    
    static let testValue = Self()
}

extension FavoritesListClient: DependencyKey {
    static let liveValue = Self(
        fetchMovies: { page, accountId in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiAccountUrl)/\(accountId)/favorite/movies?page=\(page)")!, responseType: MoviesList.self)
        },
        fetchSeries: { page, accountId in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiAccountUrl)/\(accountId)/favorite/tv?page=\(page)")!, responseType: SeriesList.self)
        },
        authorize: {
            return try await AuthorizationManager.authorize()
        },
        getSessionInfo: {
            return AuthorizationManager.getSessionInfo()
        },
        logOut: {
            return AuthorizationManager.logOut()
        }
    )
}

extension DependencyValues {
    var favoritesListClient: FavoritesListClient {
        get { self[FavoritesListClient.self] }
        set { self[FavoritesListClient.self] = newValue }
    }
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
