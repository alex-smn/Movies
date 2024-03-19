//
//  SeriesListFeature.swift
//  Movies
//
//  Created by Alexander Livshits on 17/03/2024.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SeriesListFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<SeriesDetailsFeature.State>()
        var page: Int = 1
        var totalPages: Int = 1
        var sorting: Sorting = .topRated
        var series: [SeriesListItem] = []
        var isLoading = false
        var fetchingError: String?
    }
    
    enum Action {
        case path(StackAction<SeriesDetailsFeature.State, SeriesDetailsFeature.Action>)
        case fetchSeries
        case seriesFetched(Result<SeriesList, Error>)
        case seriesPageOpened
        case listEndReached
        case sortingSet(Sorting)
    }
    
    enum Sorting {
        case topRated
        case onTheAir
        case popular
        
        var name: String {
            switch self {
            case .topRated:
                return "Top rated"
            case .onTheAir:
                return "On the air"
            case .popular:
                return "Popular"
            }
        }
        
        var urlString: String {
            switch self {
            case .topRated:
                return "\(Constants.apiTVUrlFormat)/top_rated"
            case .onTheAir:
                return "\(Constants.apiTVUrlFormat)/on_the_air"
            case .popular:
                return "\(Constants.apiTVUrlFormat)/popular"
            }
        }
    }
    
    @Dependency(\.seriesListClient) var seriesListClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchSeries:
                state.fetchingError = nil
                guard state.page <= state.totalPages else { return .none }
                state.isLoading = true
                
                return .run { [page = state.page, sorting = state.sorting] send in
                    await send(
                        .seriesFetched(
                            Result {
                                try await self.seriesListClient.fetch(page, sorting)
                            }
                        )
                    )
                }
                
            case let .seriesFetched(.success(response)):
                state.isLoading = false
                state.fetchingError = nil
                state.series = (state.series + response.results).uniqued()
                state.totalPages = response.totalPages
                
                return .none
                
            case let .seriesFetched(.failure(error)):
                state.isLoading = false
                state.fetchingError = error.localizedDescription
                
                return .none
                
            case .seriesPageOpened:
                state.page = 1
                state.series = []
                state.isLoading = false
                state.fetchingError = nil
                
                return .run { send in
                    await send(.fetchSeries)
                }
                
            case .listEndReached:
                state.page += 1
                
                return .run { send in
                    await send(.fetchSeries)
                }
                
            case let .sortingSet(sorting):
                state.page = 1
                state.series = []
                state.sorting = sorting
                
                return .run { send in
                    await send(.fetchSeries)
                }
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            SeriesDetailsFeature()
        }
    }
}
