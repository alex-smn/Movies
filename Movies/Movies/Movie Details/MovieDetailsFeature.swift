//
//  MovieDetailsFeature.swift
//  Movies
//
//  Created by Alexander Livshits on 15/03/2024.
//

import ComposableArchitecture
import Foundation

@Reducer
struct MovieDetailsFeature {
    @ObservableState
    struct State: Equatable {
        var movieId: Int
        var movie: MovieDetails?
        var videos: [Video]?
        var castPreview: [Cast]?
        var reviewsPreview: [Review]?
        var totalReviews: Int = 0
        var isLoading = false
        var hasDetailsFetchingError = false
        var hasVideosFetchingError = false
        var hasCastFetchingError = false
        var hasReviewsFetchingError = false
    }
    
    enum Action {
        case movieDetailsPageOpened
        case fetchDetails
        case detailsFetched(Result<MovieDetails, Error>)
        case fetchVideos
        case videosFetched(Result<MovieVideos, Error>)
        case fetchCast
        case castFetched(Result<MovieCast, Error>)
        case fetchReviews
        case reviewsFetched(Result<MovieReviews, Error>)
    }
    
    @Dependency(\.movieDetailsClient) var movieDetailsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .movieDetailsPageOpened:
                state.isLoading = false
                state.hasDetailsFetchingError = false
                state.hasVideosFetchingError = false
                state.hasCastFetchingError = false
                state.hasReviewsFetchingError = false
                
                return .run { send in
                    await send(.fetchDetails)
                }
                
            case .fetchDetails:
                state.isLoading = true
                state.hasDetailsFetchingError = false
                
                return .run { [movieId = state.movieId] send in
                    await send(
                        .detailsFetched(
                            Result {
                                try await self.movieDetailsClient.fetchDetails(id: movieId)
                            }
                        )
                    )
                }
                
            case let .detailsFetched(.success(response)):
                state.isLoading = false
                state.hasDetailsFetchingError = false
                state.movie = response
                
                return .run { send in
                    await send(.fetchVideos)
                }
                
            case .detailsFetched(.failure):
                state.isLoading = false
                state.hasDetailsFetchingError = true
                
                return .run { send in
                    await send(.fetchVideos)
                }
                
            case .fetchVideos:
                state.isLoading = true
                state.hasVideosFetchingError = false
                
                return .run { [movieId = state.movieId] send in
                    await send(
                        .videosFetched(
                            Result {
                                try await self.movieDetailsClient.fetchVideos(id: movieId)
                            }
                        )
                    )
                }
                
            case let .videosFetched(.success(response)):
                state.videos = response.results
                state.isLoading = false
                state.hasVideosFetchingError = false
                
                return .run { send in
                    await send(.fetchCast)
                }
                
            case .videosFetched(.failure):
                state.isLoading = false
                state.hasVideosFetchingError = true
                
                return .run { send in
                    await send(.fetchCast)
                }
                
            case .fetchCast:
                state.isLoading = true
                state.hasCastFetchingError = false
                
                return .run { [movieId = state.movieId] send in
                    await send(
                        .castFetched(
                            Result {
                                try await self.movieDetailsClient.fetchCast(id: movieId)
                            }
                        )
                    )
                }
                
            case let .castFetched(.success(response)):
                state.castPreview = Array(response.cast.prefix(10))
                state.isLoading = false
                state.hasCastFetchingError = false
                
                return .run { send in
                    await send(.fetchReviews)
                }
                
            case .castFetched(.failure):
                state.isLoading = false
                state.hasCastFetchingError = true
                
                return .run { send in
                    await send(.fetchReviews)
                }
                
            case .fetchReviews:
                state.isLoading = true
                state.hasReviewsFetchingError = false
                
                return .run { [movieId = state.movieId] send in
                    await send(
                        .reviewsFetched(
                            Result {
                                try await self.movieDetailsClient.fetchReviews(id: movieId)
                            }
                        )
                    )
                }
                
            case let .reviewsFetched(.success(response)):
                state.reviewsPreview = response.results
                state.totalReviews = response.totalResults
                state.isLoading = false
                state.hasReviewsFetchingError = false
                
                return .none
                
            case let .reviewsFetched(.failure(error)):
                print(error)
                state.isLoading = false
                state.hasReviewsFetchingError = true
                
                return .none
            }
        }
    }
}