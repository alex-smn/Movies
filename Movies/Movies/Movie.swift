//
//  Movie.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import Foundation

struct Movie: Codable, Equatable {
    let adult: Bool
    let backdropPath: String?
    let genreIds: [Int]
    let id: Int
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Float
    let posterPath: String
    let releaseDate: Date
    let title: String
    let video: Bool
    let voteAverage: Float
    let voteCount: Int
}

extension Movie {
    static func mock(id: Int) -> Movie {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return Movie(
            adult: false,
            backdropPath: "/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg",
            genreIds: [18, 80],
            id: id,
            originalLanguage: "en",
            originalTitle: "The Shawshank Redemption",
            overview: "",
            popularity: 136.526,
            posterPath: "/9cqNxx0GxF0bflZmeSMuL5tnGzr.jpg",
            releaseDate: dateFormatter.date(from: "1994-09-23") ?? Date.now,
            title: "The Shawshank Redemption",
            video: false,
            voteAverage: 8.704,
            voteCount: 25764
        )
    }
}
