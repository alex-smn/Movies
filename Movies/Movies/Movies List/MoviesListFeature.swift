//
//  MoviesListFeature.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import ComposableArchitecture
import Foundation

@Reducer
struct MoviesListFeature {
    @ObservableState
    struct State: Equatable {
        var path = StackState<MovieDetailsFeature.State>()
        var page: Int = 1
        var totalPages: Int = 1
        var sorting: Sorting = .topRated
        var movies: [MoviesListItem] = []
        var isLoading = false
        var fetchingError: String?
    }
    
    enum Action {
        case path(StackAction<MovieDetailsFeature.State, MovieDetailsFeature.Action>)
        case fetchMovies
        case moviesFetched(Result<MoviesList, Error>)
        case moviesPageOpened
        case listEndReached
        case sortingSet(Sorting)
    }
    
    enum Sorting {
        case topRated
        case nowPlaying
        case popular
        
        var name: String {
            switch self {
            case .topRated:
                return "Top rated"
            case .nowPlaying:
                return "Now playing"
            case .popular:
                return "Popular"
            }
        }
        
        var urlString: String {
            switch self {
            case .topRated:
                return "\(Constants.apiMoviesUrlFormat)/top_rated"
            case .nowPlaying:
                return "\(Constants.apiMoviesUrlFormat)/now_playing"
            case .popular:
                return "\(Constants.apiMoviesUrlFormat)/popular"
            }
        }
    }
    
    @Dependency(\.moviesListClient) var moviesListClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchMovies:
                state.fetchingError = nil
                guard state.page <= state.totalPages else { return .none }
                state.isLoading = true
                
                return .run { [page = state.page, sorting = state.sorting] send in
                    await send(
                        .moviesFetched(
                            Result {
                                try await self.moviesListClient.fetch(page, sorting)
                            }
                        )
                    )
                }
                
            case let .moviesFetched(.success(response)):
                state.isLoading = false
                state.fetchingError = nil
                state.movies = (state.movies + response.results).uniqued()
                state.totalPages = response.totalPages
                
                return .none
                
            case let .moviesFetched(.failure(error)):
                state.isLoading = false
                state.fetchingError = error.localizedDescription
                
                return .none
                
            case .moviesPageOpened:
                state.page = 1
                state.movies = []
                state.isLoading = false
                state.fetchingError = nil
                
                return .run { send in
                    await send(.fetchMovies)
                }
                
            case .listEndReached:
                state.page += 1
                
                return .run { send in
                    await send(.fetchMovies)
                }
                
            case let .sortingSet(sorting):
                state.page = 1
                state.movies = []
                state.sorting = sorting
                
                return .run { send in
                    await send(.fetchMovies)
                }
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            MovieDetailsFeature()
        }
    }
}
