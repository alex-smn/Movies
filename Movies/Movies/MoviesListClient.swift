//
//  MoviesListClient.swift
//  Movies
//
//  Created by Alexander Livshits on 15/03/2024.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct MoviesListClient {
    var fetch: @Sendable (_ page: Int, _ sorting: MoviesListFeature.Sorting) async throws -> MoviesListResponse
}

extension MoviesListClient: TestDependencyKey {
    static let previewValue = Self(
        fetch: { _, _ in
            .mockPopular
        }
    )
    
    static let testValue = Self()
}

extension MoviesListClient: DependencyKey {
    static let liveValue = Self(
        fetch: { page, sorting in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(sorting.urlString)&page=\(page)")!, responseType: MoviesListResponse.self)
        }
    )
}

extension DependencyValues {
    var moviesListClient: MoviesListClient {
        get { self[MoviesListClient.self] }
        set { self[MoviesListClient.self] = newValue }
    }
}

struct MoviesListResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
}

extension MoviesListResponse {
    static let mockPopular = Self(page: 1, results: [Movie.mock(id: 1), Movie.mock(id: 2)], totalPages: 1)
    static let mockTopRated = Self(page: 1, results: [Movie.mock(id: 3)], totalPages: 2)
    static let mockNowPlaying = Self(page: 1, results: [Movie.mock(id: 4), Movie.mock(id: 5), Movie.mock(id: 6)], totalPages: 3)
}
