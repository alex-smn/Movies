//
//  FavoritesTests.swift
//  MoviesTests
//
//  Created by Alexander Livshits on 18/03/2024.
//

import ComposableArchitecture
import XCTest

@testable import Movies

final class FavoritesTests: XCTestCase {
    @MainActor
    func testFavoritesOpened() async {
        let store = TestStore(initialState: FavoritesListFeature.State()) {
            FavoritesListFeature()
        } withDependencies: {
            $0.favoritesListClient.fetchMovies = { @Sendable _, _ in .mockFavorites }
            $0.favoritesListClient.fetchSeries = { @Sendable _, _ in .mockFavorites }
            $0.favoritesListClient.authorize = { @Sendable in ("123", 1) }
            $0.favoritesListClient.getSessionInfo = { @Sendable in ("123", 1) }
            $0.favoritesListClient.logOut = { @Sendable in }
        }
        
        await store.send(.favoritesPageOpened)
        
        await store.receive(\.getSessionInfo) {
            $0.isLoading = true
        }
        
        await store.receive(\.sessionInfoAcquired, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.accountId = 1
            $0.sessionId = "123"
        }
        
        await store.receive(\.fetchFavorites) {
            $0.isLoading = true
        }
        
        await store.receive(\.moviesFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.movies = [MoviesListItem.mock(id: 1), MoviesListItem.mock(id: 2)]
        }
        
        await store.send(.filterSet(.series)) {
            $0.filter = .series
            $0.movies = []
        }
        
        await store.receive(\.fetchFavorites) {
            $0.isLoading = true
        }
        
        await store.receive(\.seriesFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.series = [SeriesListItem.mock(id: 1), SeriesListItem.mock(id: 2)]
        }
    }
    
    @MainActor
    func testFavoritesAuthFailed() async {
        struct SomethingWrong: Error {}

        let store = TestStore(initialState: FavoritesListFeature.State()) {
            FavoritesListFeature()
        } withDependencies: {
            $0.favoritesListClient.fetchMovies = { @Sendable _, _ in .mockFavorites }
            $0.favoritesListClient.fetchSeries = { @Sendable _, _ in .mockFavorites }
            $0.favoritesListClient.authorize = { @Sendable in
                throw SomethingWrong()
            }
            $0.favoritesListClient.getSessionInfo = { @Sendable in nil }
            $0.favoritesListClient.logOut = { @Sendable in }
        }
        
        await store.send(.favoritesPageOpened)
        
        await store.receive(\.getSessionInfo) {
            $0.isLoading = true
        }
        
        await store.receive(\.sessionInfoAcquired, timeout: .seconds(1)) {
            $0.isLoading = false
        }
        
        await store.send(.authorize) {
            $0.isLoading = true
        }
        
        await store.receive(\.authorized.failure, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.hasAuthenticationError = true
        }
    }
}
