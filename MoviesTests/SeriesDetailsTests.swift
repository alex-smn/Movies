//
//  SeriesDetailsTests.swift
//  MoviesTests
//
//  Created by Alexander Livshits on 17/03/2024.
//

import ComposableArchitecture
import XCTest

@testable import Movies

final class SeriesDetailsTests: XCTestCase {
    @MainActor
    func testSeriesDetailsOpened() async {
        let store = TestStore(initialState: SeriesDetailsFeature.State(seriesId: 2)) {
            SeriesDetailsFeature()
        } withDependencies: {
            $0.seriesDetailsClient.fetchDetails = { @Sendable _ in .mock(id: 2) }
            $0.seriesDetailsClient.fetchVideos = { @Sendable _ in .mock() }
            $0.seriesDetailsClient.fetchCast = { @Sendable _ in .mock() }
            $0.seriesDetailsClient.fetchReviews = { @Sendable _ in .mock() }
        }
        
        await store.send(.seriesDetailsPageOpened)
        
        await store.receive(\.fetchDetails) {
            $0.isLoading = true
        }
        
        await store.receive(\.detailsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.series = SeriesDetails.mock(id: 2)
        }
        
        await store.receive(\.fetchVideos) {
            $0.isLoading = true
        }
        
        await store.receive(\.videosFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.videos = [Video.mock()]
        }
        
        await store.receive(\.fetchCast) {
            $0.isLoading = true
        }
        
        await store.receive(\.castFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.castPreview = [Cast.mock(), Cast.mock()]
        }
        
        await store.receive(\.fetchReviews) {
            $0.isLoading = true
        }
        
        await store.receive(\.reviewsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.reviewsPreview = [Review.mock(), Review.mock()]
            $0.totalReviews = 13
        }
    }
    
    @MainActor
    func testDetailsFetchFailure() async {
        struct SomethingWrong: Error {}
        
        let store = TestStore(initialState: SeriesDetailsFeature.State(seriesId: 2)) {
            SeriesDetailsFeature()
        } withDependencies: {
            $0.seriesDetailsClient.fetchDetails = { @Sendable _ in
                throw SomethingWrong()
            }
            $0.seriesDetailsClient.fetchVideos = { @Sendable _ in .mock() }
            $0.seriesDetailsClient.fetchCast = { @Sendable _ in .mock() }
            $0.seriesDetailsClient.fetchReviews = { @Sendable _ in .mock() }
        }
        
        await store.send(.seriesDetailsPageOpened)
        
        await store.receive(\.fetchDetails) {
            $0.isLoading = true
        }
        
        await store.receive(\.detailsFetched.failure, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.detailsFetchingError = SomethingWrong().localizedDescription
        }
        
        await store.receive(\.fetchVideos) {
            $0.isLoading = true
        }
        
        await store.receive(\.videosFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.videos = [Video.mock()]
        }
        
        await store.receive(\.fetchCast) {
            $0.isLoading = true
        }
        
        await store.receive(\.castFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.castPreview = [Cast.mock(), Cast.mock()]
        }
        
        await store.receive(\.fetchReviews) {
            $0.isLoading = true
        }
        
        await store.receive(\.reviewsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.reviewsPreview = [Review.mock(), Review.mock()]
            $0.totalReviews = 13
        }
    }
    
    @MainActor
    func testVideosFetchFailure() async {
        struct SomethingWrong: Error {}
        
        let store = TestStore(initialState: SeriesDetailsFeature.State(seriesId: 2)) {
            SeriesDetailsFeature()
        } withDependencies: {
            $0.seriesDetailsClient.fetchDetails = { @Sendable _ in .mock(id: 2) }
            $0.seriesDetailsClient.fetchVideos = { @Sendable _ in
                throw SomethingWrong()
            }
            $0.seriesDetailsClient.fetchCast = { @Sendable _ in .mock() }
            $0.seriesDetailsClient.fetchReviews = { @Sendable _ in .mock() }
        }
        
        await store.send(.seriesDetailsPageOpened)
        
        await store.receive(\.fetchDetails) {
            $0.isLoading = true
        }
        
        await store.receive(\.detailsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.series = SeriesDetails.mock(id: 2)
        }
        
        await store.receive(\.fetchVideos) {
            $0.isLoading = true
        }
        
        await store.receive(\.videosFetched.failure, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.videosFetchingError = SomethingWrong().localizedDescription
        }
        
        await store.receive(\.fetchCast) {
            $0.isLoading = true
        }
        
        await store.receive(\.castFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.castPreview = [Cast.mock(), Cast.mock()]
        }
        
        await store.receive(\.fetchReviews) {
            $0.isLoading = true
        }
        
        await store.receive(\.reviewsFetched, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.reviewsPreview = [Review.mock(), Review.mock()]
            $0.totalReviews = 13
        }
    }
    
    @MainActor
    func testCastFetchFailure() async {
        struct SomethingWrong: Error {}
        
        let store = TestStore(initialState: SeriesDetailsFeature.State(seriesId: 2)) {
            SeriesDetailsFeature()
        } withDependencies: {
            $0.seriesDetailsClient.fetchDetails = { @Sendable _ in .mock(id: 2) }
            $0.seriesDetailsClient.fetchVideos = { @Sendable _ in .mock() }
            $0.seriesDetailsClient.fetchCast = { @Sendable _ in
                throw SomethingWrong()
            }
            $0.seriesDetailsClient.fetchReviews = { @Sendable _ in .mock() }
        }
        
        await store.send(.seriesDetailsPageOpened)
        
        await store.receive(\.fetchDetails) {
            $0.isLoading = true
        }
        
        await store.receive(\.detailsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.series = SeriesDetails.mock(id: 2)
        }
        
        await store.receive(\.fetchVideos) {
            $0.isLoading = true
        }
        
        await store.receive(\.videosFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.videos = [Video.mock()]
        }
        
        await store.receive(\.fetchCast) {
            $0.isLoading = true
        }
        
        await store.receive(\.castFetched.failure, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.castFetchingError = SomethingWrong().localizedDescription
        }
        
        await store.receive(\.fetchReviews) {
            $0.isLoading = true
        }
        
        await store.receive(\.reviewsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.reviewsPreview = [Review.mock(), Review.mock()]
            $0.totalReviews = 13
        }
    }
    
    @MainActor
    func testReviewsFetchFailure() async {
        struct SomethingWrong: Error {}
        
        let store = TestStore(initialState: SeriesDetailsFeature.State(seriesId: 2)) {
            SeriesDetailsFeature()
        } withDependencies: {
            $0.seriesDetailsClient.fetchDetails = { @Sendable _ in .mock(id: 2) }
            $0.seriesDetailsClient.fetchVideos = { @Sendable _ in .mock() }
            $0.seriesDetailsClient.fetchCast = { @Sendable _ in .mock() }
            $0.seriesDetailsClient.fetchReviews = { @Sendable _ in
                throw SomethingWrong()
            }
        }
        
        await store.send(.seriesDetailsPageOpened)
        
        await store.receive(\.fetchDetails) {
            $0.isLoading = true
        }
        
        await store.receive(\.detailsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.series = SeriesDetails.mock(id: 2)
        }
        
        await store.receive(\.fetchVideos) {
            $0.isLoading = true
        }
        
        await store.receive(\.videosFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.videos = [Video.mock()]
        }
        
        await store.receive(\.fetchCast) {
            $0.isLoading = true
        }
        
        await store.receive(\.castFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.castPreview = [Cast.mock(), Cast.mock()]
        }
        
        await store.receive(\.fetchReviews) {
            $0.isLoading = true
        }
        
        await store.receive(\.reviewsFetched.failure, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.reviewsFetchingError = SomethingWrong().localizedDescription
        }
    }
}

