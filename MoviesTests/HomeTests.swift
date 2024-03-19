//
//  HomeTests.swift
//  MoviesTests
//
//  Created by Alexander Livshits on 19/03/2024.
//

import ComposableArchitecture
import XCTest

@testable import Movies

final class HomeFeatureTests: XCTestCase {
    @MainActor
    func testHomePageTrending() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.homeClient.fetchTrending = { @Sendable _, _ in .mock }
            $0.homeClient.searchMovies = { @Sendable _, _ in .mock }
            $0.homeClient.searchSeries = { @Sendable _, _ in .mock }
            $0.homeClient.searchPersons = { @Sendable _, _ in .mock }
        }
        
        await store.send(.homePageOpened)
        
        await store.receive(\.fetchTrending) {
            $0.isLoading = true
        }
        
        await store.receive(\.trendingFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.trending = [
                TrendingListItem.mock(id: 1),
                TrendingListItem.mock(id: 2, mediaType: "tv"),
                TrendingListItem.mock(id: 3)
            ]
            $0.totalTrendingPages = 2
        }
        
        await store.send(.listEndReached) {
            $0.trendingPage = 2
        }
        
        await store.receive(\.fetchTrending) {
            $0.isLoading = true
        }
        
        await store.receive(\.trendingFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.trending = [
                TrendingListItem.mock(id: 1),
                TrendingListItem.mock(id: 2, mediaType: "tv"),
                TrendingListItem.mock(id: 3)
            ]
            $0.totalTrendingPages = 2
        }
        
        await store.send(.periodChanged(.week)) {
            $0.period = .week
            $0.trending = []
        }
        
        await store.receive(\.fetchTrending) {
            $0.isLoading = true
        }
        
        await store.receive(\.trendingFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.trending = [
                TrendingListItem.mock(id: 1),
                TrendingListItem.mock(id: 2, mediaType: "tv"),
                TrendingListItem.mock(id: 3)
            ]
            $0.totalTrendingPages = 2
        }
    }
    
    @MainActor
    func testHomePageSearch() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.homeClient.fetchTrending = { @Sendable _, _ in .mock }
            $0.homeClient.searchMovies = { @Sendable _, _ in .mock }
            $0.homeClient.searchSeries = { @Sendable _, _ in .mock }
            $0.homeClient.searchPersons = { @Sendable _, _ in .mock }
        }
        
        await store.send(.searchQueryChanged("movie name")) {
            $0.searchQuery = "movie name"
        }
        
        await store.send(.searchQueryChangedDebounced) {
            $0.isLoading = true
        }
        
        await store.receive(\.searchMoviesResponse.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.searchMoviesResults = [
                SearchMoviesResult.mock(1),
                SearchMoviesResult.mock(2),
                SearchMoviesResult.mock(3)
            ]
            $0.totalSearchPages = 2
        }
        
        await store.send(.searchFilterChanged(.series)) {
            $0.searchFilter = .series
            $0.searchMoviesResults = []
        }
        
        await store.receive(\.searchQueryChangedDebounced) {
            $0.isLoading = true
        }
        
        await store.receive(\.searchSeriesResponse.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.searchSeriesResults = [
                SearchSeriesResult.mock(1),
                SearchSeriesResult.mock(2),
                SearchSeriesResult.mock(3)
            ]
            $0.totalSearchPages = 2
        }
        
        await store.send(.searchFilterChanged(.person)) {
            $0.searchFilter = .person
            $0.searchSeriesResults = []
        }
        
        await store.receive(\.searchQueryChangedDebounced) {
            $0.isLoading = true
        }
        
        await store.receive(\.searchPersonsResponse.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.searchPersonsResults = [
                SearchPersonsResult.mock(1),
                SearchPersonsResult.mock(2),
                SearchPersonsResult.mock(3)
            ]
            $0.totalSearchPages = 2
        }
    }
}
