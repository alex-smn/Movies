//
//  MovieDetailsTests.swift
//  MoviesTests
//
//  Created by Alexander Livshits on 16/03/2024.
//

import ComposableArchitecture
import XCTest

@testable import Movies

final class MovieDetailsTests: XCTestCase {
    @MainActor
    func testMovieDetailsOpened() async {
        let store = TestStore(initialState: MovieDetailsFeature.State(movieId: 2)) {
            MovieDetailsFeature()
        } withDependencies: {
            $0.movieDetailsClient.fetchDetails = { @Sendable _ in .mock(id: 2) }
            $0.movieDetailsClient.fetchVideos = { @Sendable _ in .mock() }
            $0.movieDetailsClient.fetchCast = { @Sendable _ in .mock() }
            $0.movieDetailsClient.fetchReviews = { @Sendable _ in .mock() }
        }
        
        await store.send(.movieDetailsPageOpened)
        
        await store.receive(\.fetchDetails) {
            $0.isLoading = true
        }
        
        await store.receive(\.detailsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.movie = MovieDetails.mock(id: 2)
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
        }
    }
    
    @MainActor
    func testDetailsFetchFailure() async {
        let store = TestStore(initialState: MovieDetailsFeature.State(movieId: 2)) {
            MovieDetailsFeature()
        } withDependencies: {
            $0.movieDetailsClient.fetchDetails = { @Sendable _ in
                struct SomethingWrong: Error {}
                throw SomethingWrong()
            }
            $0.movieDetailsClient.fetchVideos = { @Sendable _ in .mock() }
            $0.movieDetailsClient.fetchCast = { @Sendable _ in .mock() }
            $0.movieDetailsClient.fetchReviews = { @Sendable _ in .mock() }
        }
        
        await store.send(.movieDetailsPageOpened)
        
        await store.receive(\.fetchDetails) {
            $0.isLoading = true
        }
        
        await store.receive(\.detailsFetched.failure, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.hasDetailsFetchingError = true
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
        }
    }
    
    @MainActor
    func testVideosFetchFailure() async {
        let store = TestStore(initialState: MovieDetailsFeature.State(movieId: 2)) {
            MovieDetailsFeature()
        } withDependencies: {
            $0.movieDetailsClient.fetchDetails = { @Sendable _ in .mock(id: 2) }
            $0.movieDetailsClient.fetchVideos = { @Sendable _ in
                struct SomethingWrong: Error {}
                throw SomethingWrong()
            }
            $0.movieDetailsClient.fetchCast = { @Sendable _ in .mock() }
            $0.movieDetailsClient.fetchReviews = { @Sendable _ in .mock() }
        }
        
        await store.send(.movieDetailsPageOpened)
        
        await store.receive(\.fetchDetails) {
            $0.isLoading = true
        }
        
        await store.receive(\.detailsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.movie = MovieDetails.mock(id: 2)
        }
        
        await store.receive(\.fetchVideos) {
            $0.isLoading = true
        }
        
        await store.receive(\.videosFetched.failure, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.hasVideosFetchingError = true
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
        }
    }
    
    @MainActor
    func testCastFetchFailure() async {
        let store = TestStore(initialState: MovieDetailsFeature.State(movieId: 2)) {
            MovieDetailsFeature()
        } withDependencies: {
            $0.movieDetailsClient.fetchDetails = { @Sendable _ in .mock(id: 2) }
            $0.movieDetailsClient.fetchVideos = { @Sendable _ in .mock() }
            $0.movieDetailsClient.fetchCast = { @Sendable _ in
                struct SomethingWrong: Error {}
                throw SomethingWrong()
            }
            $0.movieDetailsClient.fetchReviews = { @Sendable _ in .mock() }
        }
        
        await store.send(.movieDetailsPageOpened)
        
        await store.receive(\.fetchDetails) {
            $0.isLoading = true
        }
        
        await store.receive(\.detailsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.movie = MovieDetails.mock(id: 2)
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
            $0.hasCastFetchingError = true
        }
        
        await store.receive(\.fetchReviews) {
            $0.isLoading = true
        }
        
        await store.receive(\.reviewsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.reviewsPreview = [Review.mock(), Review.mock()]
        }
    }
    
    @MainActor
    func testReviewsFetchFailure() async {
        let store = TestStore(initialState: MovieDetailsFeature.State(movieId: 2)) {
            MovieDetailsFeature()
        } withDependencies: {
            $0.movieDetailsClient.fetchDetails = { @Sendable _ in .mock(id: 2) }
            $0.movieDetailsClient.fetchVideos = { @Sendable _ in .mock() }
            $0.movieDetailsClient.fetchCast = { @Sendable _ in .mock() }
            $0.movieDetailsClient.fetchReviews = { @Sendable _ in
                struct SomethingWrong: Error {}
                throw SomethingWrong()
            }
        }
        
        await store.send(.movieDetailsPageOpened)
        
        await store.receive(\.fetchDetails) {
            $0.isLoading = true
        }
        
        await store.receive(\.detailsFetched.success, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.movie = MovieDetails.mock(id: 2)
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
            $0.hasReviewsFetchingError = true
        }
    }
}

