//
//  HomeClient.swift
//  Movies
//
//  Created by Alexander Livshits on 18/03/2024.
//

import ComposableArchitecture
import Foundation

// MARK: - API client interface

@DependencyClient
struct HomeClient {
    var fetchTrending: @Sendable (_ page: Int, _ period: String) async throws -> TrendingList
    var searchMovies: @Sendable (_ page: Int, _ query: String) async throws -> SearchMoviesResponse
    var searchSeries: @Sendable (_ page: Int, _ query: String) async throws -> SearchSeriesResponse
    var searchPersons: @Sendable (_ page: Int, _ query: String) async throws -> SearchPersonsResponse
}

extension HomeClient: TestDependencyKey {
    static let previewValue = Self(
        fetchTrending: { _, _ in
            .mock
        },
        searchMovies: { _, _ in
            .mock
        },
        searchSeries: { _, _ in
            .mock
        },
        searchPersons: { _, _ in
            .mock
        }
    )
    
    static let testValue = Self()
}

extension HomeClient: DependencyKey {
    static let liveValue = Self(
        fetchTrending: { page, period in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiTrendingUrl)\(period)?page=\(page)")!, responseType: TrendingList.self)
        },
        searchMovies: { page, query in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiMovieSearchUrl)?query=\(query)&page=\(page)")!, responseType: SearchMoviesResponse.self)
        },
        searchSeries: { page, query in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiTVSearchUrl)?query=\(query)&page=\(page)")!, responseType: SearchSeriesResponse.self)
        },
        searchPersons: { page, query in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiPersonSearchUrl)?query=\(query)&page=\(page)")!, responseType: SearchPersonsResponse.self)
        }
    )
}

extension DependencyValues {
    var homeClient: HomeClient {
        get { self[HomeClient.self] }
        set { self[HomeClient.self] = newValue }
    }
}

// MARK: - API Models

struct TrendingList: Codable {
    let page: Int
    let results: [TrendingListItem]
    let totalPages: Int
}

struct TrendingListItem: Codable, Equatable, Identifiable {
    let genreIds: [Int]
    let id: Int
    let originalLanguage: String
    let originalTitle: String?
    let originalName: String?
    let overview: String
    let popularity: Float
    let posterPath: String
    let mediaType: String
    let releaseDate: Date?
    let firstAirDate: Date?
    let title: String?
    let name: String?
    let voteAverage: Float
    let voteCount: Int
}

struct SearchMoviesResponse: Codable {
    let page: Int
    let results: [SearchMoviesResult]
    let totalPages: Int
}

struct SearchMoviesResult: Codable, Equatable, Identifiable {
    let genreIds: [Int]
    let id: Int
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Float
    let posterPath: String?
    let title: String
    let voteAverage: Float
    let voteCount: Int
}

struct SearchSeriesResponse: Codable {
    let page: Int
    let results: [SearchSeriesResult]
    let totalPages: Int
}

struct SearchSeriesResult: Codable, Equatable, Identifiable {
    let genreIds: [Int]
    let id: Int
    let originalLanguage: String
    let originalName: String
    let overview: String
    let popularity: Float
    let posterPath: String?
    let name: String
    let voteAverage: Float
    let voteCount: Int
}

struct SearchPersonsResponse: Codable {
    let page: Int
    let results: [SearchPersonsResult]
    let totalPages: Int
}

struct SearchPersonsResult: Codable, Equatable, Identifiable {
    let gender: Int
    let id: Int
    let originalName: String
    let popularity: Float
    let posterPath: String?
    let name: String
    let knownForDepartment: String
    let profilePath: String?
}

// MARK: - Mock data

extension TrendingList {
    static let mock = TrendingList(
        page: 1,
        results: [
            TrendingListItem.mock(id: 1),
            TrendingListItem.mock(id: 2, mediaType: "tv"),
            TrendingListItem.mock(id: 3)
        ],
        totalPages: 2
    )
}

extension TrendingListItem {
    static func mock(id: Int, mediaType: String = "movie") -> TrendingListItem {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return TrendingListItem(
            genreIds: [18, 80],
            id: id,
            originalLanguage: "en",
            originalTitle: "The Shawshank Redemption",
            originalName: "The Shawshank Redemption",
            overview: "",
            popularity: 136.526,
            posterPath: "/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg",
            mediaType: mediaType,
            releaseDate: dateFormatter.date(from: "1994-09-23") ?? Date.now,
            firstAirDate: dateFormatter.date(from: "1994-09-23") ?? Date.now,
            title: "The Shawshank Redemption",
            name: "The Shawshank Redemption",
            voteAverage: 8.704,
            voteCount: 25764
        )
    }
    
    func toMoviesListItem() -> MoviesListItem? {
        guard
            mediaType == "movie",
            let originalTitle = originalTitle,
            let title = title,
            let releaseDate = releaseDate
        else {
            return nil
        }
        return MoviesListItem(
            genreIds: genreIds,
            id: id,
            originalLanguage: originalLanguage,
            originalTitle: originalTitle,
            overview: overview,
            popularity: popularity,
            posterPath: posterPath,
            releaseDate: releaseDate ,
            title: title,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
    }
    
    func toSeriesListItem() -> SeriesListItem? {
        guard 
            mediaType == "tv",
            let originalName = originalName,
            let name = name,
            let firstAirDate = firstAirDate
        else {
            return nil
        }
        
        return SeriesListItem(
            genreIds: genreIds,
            id: id,
            originalLanguage: originalLanguage,
            originalName: originalName,
            overview: overview,
            popularity: popularity,
            posterPath: posterPath,
            firstAirDate: firstAirDate,
            name: name,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
    }
}

extension SearchMoviesResponse {
    static let mock = SearchMoviesResponse(
        page: 1,
        results: [SearchMoviesResult.mock(1), SearchMoviesResult.mock(2), SearchMoviesResult.mock(3)],
        totalPages: 2
    )
}

extension SearchSeriesResponse {
    static let mock = SearchSeriesResponse(
        page: 1,
        results: [SearchSeriesResult.mock(1), SearchSeriesResult.mock(2), SearchSeriesResult.mock(3)],
        totalPages: 2
    )
}

extension SearchPersonsResponse {
    static let mock = SearchPersonsResponse(
        page: 1,
        results: [SearchPersonsResult.mock(1), SearchPersonsResult.mock(2), SearchPersonsResult.mock(3)],
        totalPages: 2
    )
}

extension SearchMoviesResult {
    static func mock(_ id: Int) -> SearchMoviesResult {
        return SearchMoviesResult(
            genreIds: [18, 80],
            id: id,
            originalLanguage: "en",
            originalTitle: "The Shawshank Redemption",
            overview: "",
            popularity: 136.526,
            posterPath: "/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg",
            title: "The Shawshank Redemption",
            voteAverage: 8.704,
            voteCount: 25764
        )
    }
}
    
extension SearchSeriesResult {
    static func mock(_ id: Int) -> SearchSeriesResult {
        return SearchSeriesResult(
            genreIds: [18, 80],
            id: id,
            originalLanguage: "en",
            originalName: "The Shawshank Redemption",
            overview: "",
            popularity: 136.526,
            posterPath: "/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg",
            name: "The Shawshank Redemption",
            voteAverage: 8.704,
            voteCount: 25764
        )
    }
}
    
extension SearchPersonsResult {
    static func mock(_ id: Int) -> SearchPersonsResult {
        return SearchPersonsResult(
            gender: 2,
            id: id,
            originalName: "Robert De Niro",
            popularity: 136.526,
            posterPath: "/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg",
            name: "Robert De Niro",
            knownForDepartment: "Acting",
            profilePath: "/cT8htcckIuyI1Lqwt1CvD02ynTh.jpg"
        )
    }
}
