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
struct MoviesListClient {
    var fetch: @Sendable (_ page: Int, _ sorting: MoviesListFeature.Sorting) async throws -> MoviesList
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
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(sorting.urlString)?page=\(page)")!, responseType: MoviesList.self)
        }
    )
}

extension DependencyValues {
    var moviesListClient: MoviesListClient {
        get { self[MoviesListClient.self] }
        set { self[MoviesListClient.self] = newValue }
    }
}

// MARK: - API models

struct MoviesList: Codable {
    let page: Int
    let results: [MoviesListItem]
    let totalPages: Int
}

struct MoviesListItem: Codable, Equatable, Identifiable {
    let genreIds: [Int]
    let id: Int
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Float
    let posterPath: String
    let releaseDate: Date?
    let title: String
    let voteAverage: Float
    let voteCount: Int
}

// MARK: - Mock data
extension MoviesList {
    static let mockPopular = MoviesList(page: 1, results: [MoviesListItem.mock(id: 1), MoviesListItem.mock(id: 2)], totalPages: 1)
    static let mockTopRated = MoviesList(page: 1, results: [MoviesListItem.mock(id: 3)], totalPages: 2)
    static let mockNowPlaying = MoviesList(page: 1, results: [MoviesListItem.mock(id: 4), MoviesListItem.mock(id: 5), MoviesListItem.mock(id: 6)], totalPages: 3)
}

extension MoviesListItem {
    static func mock(id: Int) -> MoviesListItem {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return MoviesListItem(
            genreIds: [18, 80],
            id: id,
            originalLanguage: "en",
            originalTitle: "The Shawshank Redemption",
            overview: "",
            popularity: 136.526,
            posterPath: "/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg",
            releaseDate: dateFormatter.date(from: "1994-09-23") ?? Date.now,
            title: "The Shawshank Redemption",
            voteAverage: 8.704,
            voteCount: 25764
        )
    }
}
