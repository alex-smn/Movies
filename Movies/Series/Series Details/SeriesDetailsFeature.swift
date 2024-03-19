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
        var seriesId: Int = 0
        var series: SeriesDetails?
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
                state.detailsFetchingError = nil
                state.series = response
                
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
