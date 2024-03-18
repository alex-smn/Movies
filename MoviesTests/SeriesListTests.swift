//
//  SeriesListTests.swift
//  MoviesTests
//
//  Created by Alexander Livshits on 17/03/2024.
//

import ComposableArchitecture
import XCTest

@testable import Movies

final class SeriesListFeatureTests: XCTestCase {
    @MainActor
    func testSeriesListPageOpened() async {
        let store = TestStore(initialState: SeriesListFeature.State()) {
            SeriesListFeature()
        } withDependencies: {
            $0.seriesListClient.fetch = { @Sendable _, _ in .mockTopRated }
        }
        
        await store.send(.seriesPageOpened)
        
        await store.receive(\.fetchSeries) {
            $0.isLoading = true
        }
        
        await store.receive(\.seriesFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.series = [SeriesListItem.mock(id: 3)]
            $0.totalPages = 2
        }
    }
    
    @MainActor
    func testSeriesListSortingChanged() async {
        let store = TestStore(initialState: SeriesListFeature.State()) {
            SeriesListFeature()
        } withDependencies: {
            $0.seriesListClient.fetch = { @Sendable page, sorting in
                switch sorting {
                case .popular:
                    return .mockPopular
                case .onTheAir:
                    return .mockOnTheAir
                case .topRated:
                    return .mockTopRated
                }
            }
        }
        
        await store.send(.sortingSet(.popular)) {
            $0.sorting = .popular
        }
        
        await store.receive(\.fetchSeries) {
            $0.isLoading = true
        }
        
        await store.receive(\.seriesFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.series = [SeriesListItem.mock(id: 1), SeriesListItem.mock(id: 2)]
            $0.totalPages = 1
        }
    }
    
    @MainActor
    func testFetchFailure() async {
        let store = TestStore(initialState: SeriesListFeature.State()) {
            SeriesListFeature()
        } withDependencies: {
            $0.seriesListClient.fetch = { @Sendable _, _ in
                struct SomethingWrong: Error {}
                throw SomethingWrong()
            }
        }
        
        await store.send(.seriesPageOpened)
        
        await store.receive(\.fetchSeries) {
            $0.isLoading = true
        }
        
        await store.receive(\.seriesFetched.failure, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.hasFetchingError = true
        }
    }
}

