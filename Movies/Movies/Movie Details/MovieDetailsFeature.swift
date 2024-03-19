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
        var movieId: Int = 0
        var movie: MovieDetails?
        var videos: [Video]?
        var castPreview: [Cast]?
        var reviewsPreview: [Review]?
        var totalReviews: Int = 0
        var isLoading = false
        var detailsFetchingError: String?
        var videosFetchingError: String?
        var castFetchingError: String?
        var reviewsFetchingError: String?
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
                state.detailsFetchingError = nil
                state.videosFetchingError = nil
                state.castFetchingError = nil
                state.reviewsFetchingError = nil
                
                return .run { send in
                    await send(.fetchDetails)
                }
                
            case .fetchDetails:
                state.isLoading = true
                state.detailsFetchingError = nil
                
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
                state.detailsFetchingError = nil
                state.movie = response
                
                return .run { send in
                    await send(.fetchVideos)
                }
                
            case let .detailsFetched(.failure(error)):
                state.isLoading = false
                state.detailsFetchingError = error.localizedDescription
                
                return .run { send in
                    await send(.fetchVideos)
                }
                
            case .fetchVideos:
                state.isLoading = true
                state.videosFetchingError = nil
                
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
                state.videosFetchingError = nil
                
                return .run { send in
                    await send(.fetchCast)
                }
                
            case let .videosFetched(.failure(error)):
                state.isLoading = false
                state.videosFetchingError = error.localizedDescription
                
                return .run { send in
                    await send(.fetchCast)
                }
                
            case .fetchCast:
                state.isLoading = true
                state.castFetchingError = nil
                
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
                state.castFetchingError = nil
                
                return .run { send in
                    await send(.fetchReviews)
                }
                
            case let .castFetched(.failure(error)):
                state.isLoading = false
                state.castFetchingError = error.localizedDescription
                
                return .run { send in
                    await send(.fetchReviews)
                }
                
            case .fetchReviews:
                state.isLoading = true
                state.reviewsFetchingError = nil
                
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
                state.reviewsFetchingError = nil
                
                return .none
                
            case let .reviewsFetched(.failure(error)):
                state.isLoading = false
                state.reviewsFetchingError = error.localizedDescription
                
                return .none
            }
        }
    }
}
