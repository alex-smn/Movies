//
//  MovieDetailsClient.swift
//  Movies
//
//  Created by Alexander Livshits on 15/03/2024.
//

import ComposableArchitecture
import Foundation

// MARK: - API client interface

@DependencyClient
struct MovieDetailsClient {
    var fetchDetails: @Sendable (_ id: Int) async throws -> MovieDetails
    var fetchVideos: @Sendable (_ id: Int) async throws -> MovieVideos
    var fetchCast: @Sendable (_ id: Int) async throws -> MovieCast
    var fetchReviews: @Sendable (_ id: Int) async throws -> MovieReviews
}

extension MovieDetailsClient: TestDependencyKey {
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

extension MovieDetailsClient: DependencyKey {
    static let liveValue = Self(
        fetchDetails: { id in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiMoviesUrlFormat)/\(id)")!, responseType: MovieDetails.self)
        },
        fetchVideos: { id in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiMoviesUrlFormat)/\(id)/videos")!, responseType: MovieVideos.self)
        },
        fetchCast: { id in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiMoviesUrlFormat)/\(id)/credits")!, responseType: MovieCast.self)
        },
        fetchReviews: { id in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(Constants.apiMoviesUrlFormat)/\(id)/reviews")!, responseType: MovieReviews.self)
        }
    )
}

extension DependencyValues {
    var movieDetailsClient: MovieDetailsClient {
        get { self[MovieDetailsClient.self] }
        set { self[MovieDetailsClient.self] = newValue }
    }
}

// MARK: - API models

struct MovieDetails: Codable, Equatable {
    let backdropPath: String
    let budget: Int
    let genres: [Genre]
    let id: Int
    let imdbId: String
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Float
    let posterPath: String
    let releaseDate: Date
    let revenue: Int
    let tagline: String
    let title: String
    let voteAverage: Float
    let voteCount: Int
}

struct Genre: Codable, Equatable {
    let id: Int
    let name: String
}

struct MovieVideos: Codable, Equatable {
    let id: Int
    let results: [Video]
}

struct Video: Codable, Equatable {
    let iso6391: String
    let iso31661: String
    let name: String
    let key: String
    let site: String
    let size: Int
    let type: String
    let official: Bool
    let id: String
}

struct MovieCast: Codable, Equatable {
    let id: Int
    let cast: [Cast]
}

struct Cast: Codable, Equatable {
    let adult: Bool
    let gender: Int
    let id: Int
    let knownForDepartment: String
    let name: String
    let originalName: String
    let popularity: Float
    let profilePath: String?
    let castId: Int
    let character: String
    let creditId: String
    let order: Int
}

struct MovieReviews: Codable, Equatable {
    let id: Int
    let page: Int
    let results: [Review]
    let totalPages: Int
    let totalResults: Int
}

struct Review: Codable, Equatable {
    let author: String
    let authorDetails: Author
    let content: String
    let id: String
    let url: String
}

struct Author: Codable, Equatable {
    let name: String
    let username: String
    let avatarPath: String?
    let rating: Int?
}

// MARK: - Mock data

extension MovieDetails {
    static func mock(id: Int) -> MovieDetails {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return Self(
            backdropPath: "/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg",
            budget: 25000000,
            genres: [Genre(id: 18, name: "Drama"), Genre(id: 80, name: "Crime")],
            id: id,
            imdbId: "tt0111161",
            originalLanguage: "en",
            originalTitle: "The Shawshank Redemption",
            overview: "Framed in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison, where he puts his accounting skills to work for an amoral warden. During his long stretch in prison, Dufresne comes to be admired by the other inmates -- including an older prisoner named Red -- for his integrity and unquenchable sense of hope.",
            popularity: 135.479,
            posterPath: "/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg",
            releaseDate: dateFormatter.date(from: "1994-09-23") ?? Date.now,
            revenue: 28341469,
            tagline: "Fear can hold you prisoner. Hope can set you free.",
            title: "The Shawshank Redemption",
            voteAverage: 8.704,
            voteCount: 25767
        )
    }
}

extension MovieVideos {
    static func mock() -> MovieVideos {
        Self(id: 278, results: [Video.mock()])
    }
}

extension Video {
    static func mock() -> Video {
        Self(
            iso6391: "en",
            iso31661: "US", 
            name: "Trailer",
            key: "PLl99DlL6b4",
            site: "YouTube",
            size: 2160,
            type: "Trailer",
            official: true,
            id: "6100de6e22931a00297462fe"
        )
    }
}

extension MovieCast {
    static func mock() -> MovieCast {
        Self(
            id: 278,
            cast: [Cast.mock(), Cast.mock()]
        )
    }
}

extension Cast {
    static func mock() -> Cast {
        Self(
            adult: false,
            gender: 2,
            id: 504,
            knownForDepartment: "Acting",
            name: "Tim Robbins",
            originalName: "Tim Robbins",
            popularity: 33.542,
            profilePath: "/A4fHNLX73EQs78f2G6ObfKZnvp4.jpg",
            castId: 3,
            character: "Andy Dufresne",
            creditId: "52fe4231c3a36847f800b131",
            order: 0
        )
    }
}

extension MovieReviews {
    static func mock() -> MovieReviews {
        Self(
            id: 278,
            page: 1,
            results: [Review.mock(), Review.mock()],
            totalPages: 1,
            totalResults: 13
        )
    }
}

extension Review {
    static func mock() -> Review {
        Self(
            author: "username",
            authorDetails: Author.mock(),
            content: "Very good movie 9.5/10",
            id: "5723a329c3a3682e720005db",
            url: "https://www.themoviedb.org/review/5723a329c3a3682e720005db"
        )
    }
}

extension Author {
    static func mock() -> Author {
        Self(
            name: "",
            username: "username", 
            avatarPath: "/utEXl2EDiXBK6f41wCLsvprvMg4.jpg",
            rating: 9
        )
    }
}