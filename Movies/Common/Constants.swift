//
//  Constants.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import Foundation

struct Constants {
    static let apiAccessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0YzY5NmU2ODI0MDVlYzUwOTNlMmIzMmU2ZmZlMzUwNCIsInN1YiI6IjY1ZjMwYzg3ZWVhMzRkMDE2NDE0NWVmOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Y2Nn-KYsmVrSBBw_EVEZhAJ2-IfLfXgxz4K7iUDO-5k"
    static let apiMoviesUrlFormat = "https://api.themoviedb.org/3/movie"
    static let apiTVUrlFormat = "https://api.themoviedb.org/3/tv"
    static let apiFavoritesUrlFormat = "https://api.themoviedb.org/3/account/"
    static let apiRequestTokenUrl = "https://api.themoviedb.org/3/authentication/token/new"
    static let tokenApproveUrl = "https://www.themoviedb.org/authenticate/"
    static let apiCreateSessionIDUrl = "https://api.themoviedb.org/3/authentication/session/new"
    static let apiAccountDetailsUrl = "https://api.themoviedb.org/3/account"
    static let posterUrlFormat = "https://image.tmdb.org/t/p/w200"
    static let backdropUrlFormat = "https://image.tmdb.org/t/p/w640_and_h360_bestv2"
    static let castImageUrlFormat = "https://media.themoviedb.org/t/p/w276_and_h350_face"
    static let reviewAuthorImageUrlFormat = "https://media.themoviedb.org/t/p/w90_and_h90_face"
}
