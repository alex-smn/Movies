//
//  MoviesListTests.swift
//  MoviesTests
//
//  Created by Alexander Livshits on 15/03/2024.
//

import ComposableArchitecture
import XCTest

@testable import Movies

final class MoviesListFeatureTests: XCTestCase {
    @MainActor
    func testMoviesListPageOpened() async {
        let store = TestStore(initialState: MoviesListFeature.State()) {
            MoviesListFeature()
        } withDependencies: {
            $0.moviesListClient.fetch = { @Sendable _, _ in .mockTopRated }
        }
        
        await store.send(.moviesPageOpened)
        
        await store.receive(\.fetchMovies) {
            $0.isLoading = true
        }
        
        await store.receive(\.moviesFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.movies = [Movie.mock(id: 3)]
            $0.totalPages = 2
        }
    }
    
    @MainActor
    func testMoviesListSortingChanged() async {
        let store = TestStore(initialState: MoviesListFeature.State()) {
            MoviesListFeature()
        } withDependencies: {
            $0.moviesListClient.fetch = { @Sendable page, sorting in
                switch sorting {
                case .popular:
                    return .mockPopular
                case .nowPlaying:
                    return .mockNowPlaying
                case .topRated:
                    return .mockTopRated
                }
            }
        }
        
        await store.send(.sortingSet(.popular)) {
            $0.sorting = .popular
        }
        
        await store.receive(\.fetchMovies) {
            $0.isLoading = true
        }
        
        await store.receive(\.moviesFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.movies = [Movie.mock(id: 1), Movie.mock(id: 2)]
            $0.totalPages = 1
        }
    }
}

