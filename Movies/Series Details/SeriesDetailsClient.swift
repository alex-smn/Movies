//
//  SeriesDetailsClient.swift
//  Movies
//
//  Created by Alexander Livshits on 17/03/2024.
//

import ComposableArchitecture
import Foundation

// MARK: - API client interface

@DependencyClient
struct SeriesDetailsClient {
    var fetchDetails: @Sendable (_ id: Int) async throws -> SeriesDetails
    var fetchVideos: @Sendable (_ id: Int) async throws -> SeriesVideos
    var fetchCast: @Sendable (_ id: Int) async throws -> SeriesCast
    var fetchReviews: @Sendable (_ id: Int) async throws -> SeriesReviews
}

extension SeriesDetailsClient: TestDependencyKey {
    static let previewValue = Self(
        fetchDetails: { _ in
            .mock(id: 3)
        },
        fetchVideos: { _ in
            .mock()
        },
        fetchCast: { _ in
            .mock()
        },
        fetchReviews: { _ in
            .mock()
        }
    )
    
    static let testValue = Self()
}

extension SeriesDetailsClient: DependencyKey {
    static let liveValue = Self(
        fetchDetails: { id in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiTVUrlFormat)/\(id)")!, responseType: SeriesDetails.self)
        },
        fetchVideos: { id in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiTVUrlFormat)/\(id)/videos")!, responseType: SeriesVideos.self)
        },
        fetchCast: { id in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiTVUrlFormat)/\(id)/credits")!, responseType: SeriesCast.self)
        },
        fetchReviews: { id in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiTVUrlFormat)/\(id)/reviews")!, responseType: SeriesReviews.self)
        }
    )
}

extension DependencyValues {
    var seriesDetailsClient: SeriesDetailsClient {
        get { self[SeriesDetailsClient.self] }
        set { self[SeriesDetailsClient.self] = newValue }
    }
}

// MARK: - API models

struct SeriesDetails: Codable, Equatable {
    let backdropPath: String
    let episodeRunTime: [Int?]
    let firstAirDate: Date
    let genres: [Genre]
    let id: Int
    let inProduction: Bool
    let lastAirDate: Date
    let lastEpisodeToAir: Episode
    let nextEpisodeToAir: Episode?
    let originalLanguage: String
    let originalName: String
    let numberOfEpisodes: Int
    let numberOfSeasons: Int
    let overview: String
    let popularity: Float
    let posterPath: String
    let seasons: [Season]
    let tagline: String
    let name: String
    let voteAverage: Float
    let voteCount: Int
    let status: String
    let type: String
}

struct Episode: Codable, Equatable {
    let id: Int
    let name: String
    let overview: String
    let voteAverage: Float
    let voteCount: Int
    let airDate: Date
    let episodeNumber: Int
    let episodeType: String?
    let runtime: Int?
    let seasonNumber: Int
    let showId: Int
    let stillPath: String?
}

struct Season: Codable, Equatable {
    let airDate: Date?
    let episodeCount: Int?
    let id: Int
    let name: String?
    let overview: String
    let posterPath: String?
    let seasonNumber: Int?
    let voteAverage: Float
}

struct SeriesVideos: Codable, Equatable {
    let id: Int
    let results: [Video]
}

struct SeriesCast: Codable, Equatable {
    let id: Int
    let cast: [Cast]
}

struct SeriesReviews: Codable, Equatable {
    let id: Int
    let page: Int
    let results: [Review]
    let totalPages: Int
    let totalResults: Int
}

// MARK: - Mock data

extension SeriesDetails {
    static func mock(id: Int) -> SeriesDetails {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return SeriesDetails(
            backdropPath: "/9faGSFi5jam6pDWGNd0p8JcJgXQ.jpg",
            episodeRunTime: [],
            firstAirDate: dateFormatter.date(from: "2013-09-29") ?? Date.now,
            genres: [Genre.mock(), Genre.mock()],
            id: 1396,
            inProduction: false,
            lastAirDate: dateFormatter.date(from: "2013-09-29") ?? Date.now,
            lastEpisodeToAir: Episode.mock(),
            nextEpisodeToAir: nil,
            originalLanguage: "en",
            originalName: "Breaking Bad",
            numberOfEpisodes: 62,
            numberOfSeasons: 5,
            overview: "Walter White, a New Mexico chemistry teacher, is diagnosed with Stage III cancer and given a prognosis of only two years left to live. He becomes filled with a sense of fearlessness and an unrelenting desire to secure his family's financial future at any cost as he enters the dangerous world of drugs and crime.",
            popularity: 674.69,
            posterPath: "/ztkUQFLlC19CCMYHW9o1zWhJRNq.jpg",
            seasons: [Season.mock(), Season.mock()],
            tagline: "Change the equation.",
            name: "Breaking Bad",
            voteAverage: 8.905,
            voteCount: 13258,
            status: "Ended",
            type: "Scripted"
        )
    }
}

extension Episode {
    static func mock() -> Episode {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return Episode(
            id: 62161,
            name: "Felina",
            overview: "All bad things must come to an end.",
            voteAverage: 9.204,
            voteCount: 206,
            airDate: dateFormatter.date(from: "2013-09-29") ?? Date.now,
            episodeNumber: 16,
            episodeType: "finale",
            runtime: 56,
            seasonNumber: 5,
            showId: 1396,
            stillPath: "/pA0YwyhvdDXP3BEGL2grrIhq8aM.jpg"
        )
    }
}

extension Season {
    static func mock() -> Season {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return Season(
            airDate: dateFormatter.date(from: "2008-01-20") ?? Date.now,
            episodeCount: 7,
            id: 3572,
            name: "Season 1",
            overview: "High school chemistry teacher Walter White's life is suddenly transformed by a dire medical diagnosis. Street-savvy former student Jesse Pinkman \"teaches\" Walter a new trade.",
            posterPath: "/1BP4xYv9ZG4ZVHkL7ocOziBbSYH.jpg",
            seasonNumber: 1,
            voteAverage: 8.3
        )
    }
}

extension SeriesVideos {
    static func mock() -> SeriesVideos {
        SeriesVideos(id: 278, results: [Video.mock()])
    }
}
extension SeriesCast {
    static func mock() -> SeriesCast {
        SeriesCast(
            id: 278,
            cast: [Cast.mock(), Cast.mock()]
        )
    }
}

extension SeriesReviews {
    static func mock() -> SeriesReviews {
        SeriesReviews(
            id: 278,
            page: 1,
            results: [Review.mock(), Review.mock()],
            totalPages: 1,
            totalResults: 13
        )
    }
}
