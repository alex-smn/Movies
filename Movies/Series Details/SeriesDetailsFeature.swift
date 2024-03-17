//
//  SeriesDetailsFeature.swift
//  Movies
//
//  Created by Alexander Livshits on 17/03/2024.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SeriesDetailsFeature {
    @ObservableState
    struct State: Equatable {
        var seriesId: Int
        var series: SeriesDetails?
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
        case seriesDetailsPageOpened
        case fetchDetails
        case detailsFetched(Result<SeriesDetails, Error>)
        case fetchVideos
        case videosFetched(Result<SeriesVideos, Error>)
        case fetchCast
        case castFetched(Result<SeriesCast, Error>)
        case fetchReviews
        case reviewsFetched(Result<SeriesReviews, Error>)
    }
    
    @Dependency(\.seriesDetailsClient) var seriesDetailsClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .seriesDetailsPageOpened:
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
                
                return .run { [seriesId = state.seriesId] send in
                    await send(
                        .detailsFetched(
                            Result {
                                try await self.seriesDetailsClient.fetchDetails(id: seriesId)
                            }
                        )
                    )
                }
                
            case let .detailsFetched(.success(response)):
                state.isLoading = false
                state.hasDetailsFetchingError = false
                state.series = response
                
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
                
                return .run { [seriesId = state.seriesId] send in
                    await send(
                        .videosFetched(
                            Result {
                                try await self.seriesDetailsClient.fetchVideos(id: seriesId)
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
                
                return .run { [seriesId = state.seriesId] send in
                    await send(
                        .castFetched(
                            Result {
                                try await self.seriesDetailsClient.fetchCast(id: seriesId)
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
                
                return .run { [seriesId = state.seriesId] send in
                    await send(
                        .reviewsFetched(
                            Result {
                                try await self.seriesDetailsClient.fetchReviews(id: seriesId)
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
                
            case .reviewsFetched(.failure):
                state.isLoading = false
                state.hasReviewsFetchingError = true
                
                return .none
            }
        }
    }
}
