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
            $0.favoritesListClient.requestToken = { @Sendable in .mock }
            $0.favoritesListClient.authenticate = { @Sendable _ in true}
            $0.favoritesListClient.createSessionId = { @Sendable _ in .mock }
            $0.favoritesListClient.getAccountDetails = { @Sendable _ in .mock }
        }
        
        await store.send(.favoritesPageOpened)
        
        await store.receive(\.requestToken) {
            $0.isLoading = true
        }
        
        await store.receive(\.tokenGenerated.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.token = RequestToken.mock.requestToken
        }
        
        await store.receive(\.authenticate) {
            $0.isLoading = true
        }
        
        await store.receive(\.authenticated.success, timeout: .seconds(1)) {
            $0.isLoading = false
        }
        
        await store.receive(\.createSessionId) {
            $0.isLoading = true
        }
        
        await store.receive(\.sessionIdCreated.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.sessionId = Session.mock.sessionId
        }
        
        await store.receive(\.getAccountDetails) {
            $0.isLoading = true
        }
        
        await store.receive(\.accountDetailsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.accountId = Account.mock.id
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
        let store = TestStore(initialState: FavoritesListFeature.State()) {
            FavoritesListFeature()
        } withDependencies: {
            $0.favoritesListClient.fetchMovies = { @Sendable _, _ in .mockFavorites }
            $0.favoritesListClient.fetchSeries = { @Sendable _, _ in .mockFavorites }
            $0.favoritesListClient.requestToken = { @Sendable in .mock }
            $0.favoritesListClient.authenticate = { @Sendable _ in false}
            $0.favoritesListClient.createSessionId = { @Sendable _ in .mock }
            $0.favoritesListClient.getAccountDetails = { @Sendable _ in .mock }
        }
        
        await store.send(.favoritesPageOpened)
        
        await store.receive(\.requestToken) {
            $0.isLoading = true
        }
        
        await store.receive(\.tokenGenerated.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.token = RequestToken.mock.requestToken
        }
        
        await store.receive(\.authenticate) {
            $0.isLoading = true
        }
        
        await store.receive(\.authenticated.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.hasAuthenticationError = true
        }
    }
}
//
//    @MainActor
//    func testDetailsFetchFailure() async {
//        let store = TestStore(initialState: SeriesDetailsFeature.State(seriesId: 2)) {
//            SeriesDetailsFeature()
//        } withDependencies: {
//            $0.seriesDetailsClient.fetchDetails = { @Sendable _ in
//                struct SomethingWrong: Error {}
//                throw SomethingWrong()
//            }
//            $0.seriesDetailsClient.fetchVideos = { @Sendable _ in .mock() }
//            $0.seriesDetailsClient.fetchCast = { @Sendable _ in .mock() }
//            $0.seriesDetailsClient.fetchReviews = { @Sendable _ in .mock() }
//        }
//        
//        await store.send(.seriesDetailsPageOpened)
//        
//        await store.receive(\.fetchDetails) {
//            $0.isLoading = true
//        }
//        
//        await store.receive(\.detailsFetched.failure, timeout: .seconds(1)) {
//            $0.isLoading = false
//            $0.hasDetailsFetchingError = true
//        }
//        
//        await store.receive(\.fetchVideos) {
//            $0.isLoading = true
//        }
//        
//        await store.receive(\.videosFetched.success, timeout: .seconds(1)) {
//            $0.isLoading = false
//            $0.videos = [Video.mock()]
//        }
//        
//        await store.receive(\.fetchCast) {
//            $0.isLoading = true
//        }
//        
//        await store.receive(\.castFetched.success, timeout: .seconds(1)) {
//            $0.isLoading = false
//            $0.castPreview = [Cast.mock(), Cast.mock()]
//        }
//        
//        await store.receive(\.fetchReviews) {
//            $0.isLoading = true
//        }
//        
//        await store.receive(\.reviewsFetched.success, timeout: .seconds(1)) {
//            $0.isLoading = false
//            $0.reviewsPreview = [Review.mock(), Review.mock()]
//            $0.totalReviews = 13
//        }
//    }
//}
