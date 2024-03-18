//
//  SeriesListClient.swift
//  Movies
//
//  Created by Alexander Livshits on 17/03/2024.
//

import ComposableArchitecture
import Foundation

// MARK: - API client interface

@DependencyClient
struct SeriesListClient {
    var fetch: @Sendable (_ page: Int, _ sorting: SeriesListFeature.Sorting) async throws -> SeriesList
}

extension SeriesListClient: TestDependencyKey {
    static let previewValue = Self(
        fetch: { _, _ in
            .mockPopular
        }
    )
    
    static let testValue = Self()
}

extension SeriesListClient: DependencyKey {
    static let liveValue = Self(
        fetch: { page, sorting in
            return try await NetworkHelper.performNetworkRequest(url: URL(string: "\(sorting.urlString)?page=\(page)")!, responseType: SeriesList.self)
        }
    )
}

extension DependencyValues {
    var seriesListClient: SeriesListClient {
        get { self[SeriesListClient.self] }
        set { self[SeriesListClient.self] = newValue }
    }
}

// MARK: - API models

struct SeriesList: Codable {
    let page: Int
    let results: [SeriesListItem]
    let totalPages: Int
}

struct SeriesListItem: Codable, Equatable {
    let genreIds: [Int]
    let id: Int
    let originalLanguage: String
    let originalName: String
    let overview: String
    let popularity: Float
    let posterPath: String?
    let firstAirDate: Date
    let name: String
    let voteAverage: Float
    let voteCount: Int
}

// MARK: - Mock data

extension SeriesListItem {
    static func mock(id: Int) -> SeriesListItem {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return SeriesListItem(
            genreIds: [18, 80],
            id: id,
            originalLanguage: "en",
            originalName: "Breaking Bad",
            overview: "Walter White, a New Mexico chemistry teacher, is diagnosed with Stage III cancer and given a prognosis of only two years left to live. He becomes filled with a sense of fearlessness and an unrelenting desire to secure his family's financial future at any cost as he enters the dangerous world of drugs and crime.",
            popularity: 674.69,
            posterPath: "/ztkUQFLlC19CCMYHW9o1zWhJRNq.jpg",
            firstAirDate: dateFormatter.date(from: "2008-01-20") ?? Date.now,
            name: "Breaking Bad",
            voteAverage: 8.905,
            voteCount: 25764
        )
    }
}

extension SeriesList {
    static let mockPopular = SeriesList(page: 1, results: [SeriesListItem.mock(id: 1), SeriesListItem.mock(id: 2)], totalPages: 1)
    static let mockTopRated = SeriesList(page: 1, results: [SeriesListItem.mock(id: 3)], totalPages: 2)
    static let mockOnTheAir = SeriesList(page: 1, results: [SeriesListItem.mock(id: 4), SeriesListItem.mock(id: 5), SeriesListItem.mock(id: 6)], totalPages: 3)
}
