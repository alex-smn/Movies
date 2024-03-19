//
//  HomeFeature.swift
//  Movies
//
//  Created by Alexander Livshits on 18/03/2024.
//

import ComposableArchitecture

@Reducer
struct HomeFeature {
    @Reducer(state: .equatable)
    enum Path {
        case movie(MovieDetailsFeature)
        case series(SeriesDetailsFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var trendingPage: Int = 1
        var searchPage: Int = 1
        var isLoading = false
        var fetchingError: String?
        var searchError: String?
        var period: Period = .day
        var totalTrendingPages: Int = 1
        var totalSearchPages: Int = 1
        var trending: [TrendingListItem] = []
        var searchQuery = ""
        var searchFilter: SearchFilter = .movies
        var searchMoviesResults: [SearchMoviesResult] = []
        var searchSeriesResults: [SearchSeriesResult] = []
        var searchPersonsResults: [SearchPersonsResult] = []
    }
    
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case homePageOpened
        case fetchTrending
        case trendingFetched(Result<TrendingList, Error>)
        case listEndReached
        case periodChanged(Period)
        case searchFilterChanged(SearchFilter)
        case searchQueryChanged(String)
        case searchQueryChangedDebounced
        case searchMoviesResponse(Result<SearchMoviesResponse, Error>)
        case searchSeriesResponse(Result<SearchSeriesResponse, Error>)
        case searchPersonsResponse(Result<SearchPersonsResponse, Error>)
    }
    
    enum Period {
        case day
        case week
        
        var name: String {
            switch self {
            case .day:
                return "day"
            case .week:
                return "week"
            }
        }
    }
    
    enum SearchFilter {
        case movies, series, person
        
        var name: String {
            switch self {
            case .movies:
                return "movie"
            case .series:
                return "tv"
            case .person:
                return "person"
            }
        }
    }
    
    enum CancelID {
        case trending
        case search
    }
    
    @Dependency(\.homeClient) var homeClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .homePageOpened:
                state.trendingPage = 1
                state.isLoading = false
                state.fetchingError = nil
                
                return .run { send in
                    await send(.fetchTrending)
                }
                
            case .fetchTrending:
                state.fetchingError = nil
                guard state.trendingPage <= state.totalTrendingPages else { return .none }
                state.isLoading = true
                
                return .run { [page = state.trendingPage, period = state.period.name] send in
                    await send(
                        .trendingFetched(
                            Result {
                                try await self.homeClient.fetchTrending(page, period)
                            }
                        )
                    )
                }
                .cancellable(id: CancelID.trending, cancelInFlight: true)
                
            case let .trendingFetched(.success(result)):
                state.isLoading = false
                state.trending = (state.trending + result.results).uniqued()
                state.totalTrendingPages = result.totalPages
                
                return .none
                
            case let .trendingFetched(.failure(error)):
                state.isLoading = false
                state.fetchingError = error.localizedDescription
                
                return .none
                
            case .listEndReached:
                state.trendingPage += 1
                
                return .run { send in
                    await send(.fetchTrending)
                }
                
            case let .periodChanged(period):
                state.period = period
                state.trending = []
                
                return .run { send in
                    await send(.fetchTrending)
                }
                
            case let .searchQueryChanged(query):
                state.searchQuery = query
                guard !state.searchQuery.isEmpty else {
                    state.searchMoviesResults = []
                    state.searchSeriesResults = []
                    state.searchPersonsResults = []
                    return .cancel(id: CancelID.search)
                }
                
                return .none
                
            case .searchQueryChangedDebounced:
                state.searchError = nil
                guard !state.searchQuery.isEmpty else { return .none }
                state.isLoading = true
                
                return .run { [page = state.searchPage, query = state.searchQuery, filter = state.searchFilter] send in
                    switch filter {
                    case .movies:
                        await send(
                            .searchMoviesResponse(
                                Result {
                                    try await self.homeClient.searchMovies(page, query)
                                }
                            )
                        )
                    case .series:
                        await send(
                            .searchSeriesResponse(
                                Result {
                                    try await self.homeClient.searchSeries(page, query)
                                }
                            )
                        )
                        
                    case .person:
                        await send(
                            .searchPersonsResponse(
                                Result {
                                    try await self.homeClient.searchPersons(page, query)
                                }
                            )
                        )
                    }
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)
                
            case let .searchMoviesResponse(.success(result)):
                state.isLoading = false
                state.searchError = nil
                state.searchMoviesResults = result.results.uniqued()
                state.totalSearchPages = result.totalPages
                state.searchSeriesResults = []
                state.searchPersonsResults = []
                
                return .none
                
            case let .searchMoviesResponse(.failure(error)):
                state.isLoading = false
                state.searchError = error.localizedDescription
                state.searchMoviesResults = []
                state.searchSeriesResults = []
                state.searchPersonsResults = []
                
                return .none
            
            case let .searchSeriesResponse(.success(result)):
                state.isLoading = false
                state.searchError = nil
                state.searchSeriesResults = result.results.uniqued()
                state.totalSearchPages = result.totalPages
                state.searchMoviesResults = []
                state.searchPersonsResults = []
                
                return .none
                
            case let .searchSeriesResponse(.failure(error)):
                state.isLoading = false
                state.searchError = error.localizedDescription
                state.searchMoviesResults = []
                state.searchSeriesResults = []
                state.searchPersonsResults = []
                
                return .none
            
            case let .searchPersonsResponse(.success(result)):
                state.isLoading = false
                state.searchError = nil
                state.searchPersonsResults = result.results.uniqued()
                state.totalSearchPages = result.totalPages
                state.searchMoviesResults = []
                state.searchSeriesResults = []
                
                return .none
                
            case let .searchPersonsResponse(.failure(error)):
                state.isLoading = false
                state.searchError = error.localizedDescription
                state.searchMoviesResults = []
                state.searchSeriesResults = []
                state.searchPersonsResults = []
                
                return .none
                
            case let .searchFilterChanged(filter):
                state.searchFilter = filter
                state.searchMoviesResults = []
                state.searchSeriesResults = []
                state.searchPersonsResults = []
                
                return .run { send in
                    await send(.searchQueryChangedDebounced)
                }
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
