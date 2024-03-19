//
//  FavoritesListFeature.swift
//  Movies
//
//  Created by Alexander Livshits on 17/03/2024.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct FavoritesListFeature {
    @Reducer(state: .equatable)
    enum Path {
        case movie(MovieDetailsFeature)
        case series(SeriesDetailsFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var accountId: Int?
        var token: String?
        var sessionId: String?
        var page: Int = 1
        var totalPages: Int = 1
        var filter: Filter = .movies
        var movies: [MoviesListItem] = []
        var series: [SeriesListItem] = []
        var isLoading = false
        var fetchingError: String?
        var hasAuthenticationError = false
    }
    
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case authorize
        case authorized(Result<(sessionId: String, accountId: Int), Error>)
        case getSessionInfo
        case sessionInfoAcquired((sessionId: String, accountId: Int)?)
        case logOut
        case loggedOut
        case fetchFavorites
        case moviesFetched(Result<MoviesList, Error>)
        case seriesFetched(Result<SeriesList, Error>)
        case favoritesPageOpened
        case listEndReached
        case filterSet(Filter)
    }
    
    enum Filter {
        case movies
        case series
        
        var name: String {
            switch self {
            case .movies:
                return "Movies"
            case .series:
                return "Series"
            }
        }
    }
    
    @Dependency(\.favoritesListClient) var favoritesListClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .favoritesPageOpened:
                state.page = 1
                state.movies = []
                state.series = []
                state.isLoading = false
                state.fetchingError = nil
                
                if state.accountId != nil {
                    return .run { send in
                        await send(.fetchFavorites)
                    }
                } else {
                    return .run { send in
                        await send(.getSessionInfo)
                    }
                }
                
            case .listEndReached:
                state.page += 1
                
                return .run { send in
                    await send(.fetchFavorites)
                }
                
            case let .filterSet(filter):
                state.page = 1
                state.hasAuthenticationError = false
                state.movies = []
                state.series = []
                state.filter = filter
                
                return .run { send in
                    await send(.fetchFavorites)
                }
                
            case .authorize:
                state.isLoading = true
                
                return .run { send in
                    await send(
                        .authorized(
                            Result {
                                try await self.favoritesListClient.authorize()
                            }
                        )
                    )
                }
                
            case let .authorized(.success(info)):
                state.isLoading = false
                state.hasAuthenticationError = false
                state.sessionId = info.sessionId
                state.accountId = info.accountId
                    
                return .run { send in
                    await send(.fetchFavorites)
                }
                
            case .authorized(.failure):
                state.isLoading = false
                state.hasAuthenticationError = true
                
                return .none
                
            case .getSessionInfo:
                state.isLoading = true
                state.hasAuthenticationError = false
                
                return .run { send in
                    await send(
                        .sessionInfoAcquired(
                            self.favoritesListClient.getSessionInfo()
                        )
                    )
                }
                
            case let .sessionInfoAcquired(info):
                state.isLoading = false
                if let info {
                    state.sessionId = info.sessionId
                    state.accountId = info.accountId
                    return .run { send in
                        await send(.fetchFavorites)
                    }
                }
                    
                return .none
                
            case .logOut:
                state.isLoading = true
                self.favoritesListClient.logOut()
                
                return .run { send in
                    await send(.loggedOut)
                }
                
            case .loggedOut:
                state.isLoading = false
                state.sessionId = nil
                state.accountId = nil
                state.movies = []
                state.series = []
                state.page = 1
                state.totalPages = 1
                
                return .none
                
            case .fetchFavorites:
                state.fetchingError = nil
                guard state.page <= state.totalPages else { return .none }
                state.isLoading = true
                
                if let accountId = state.accountId {
                    return .run { [page = state.page, filter = state.filter, accountId = accountId] send in
                        switch filter {
                        case .movies:
                            await send(
                                .moviesFetched(
                                    Result {
                                        try await self.favoritesListClient.fetchMovies(page, accountId)
                                    }
                                )
                            )
                            
                        case .series:
                            await send(
                                .seriesFetched(
                                    Result {
                                        try await self.favoritesListClient.fetchSeries(page, accountId)
                                    }
                                )
                            )
                        }
                    }
                } else {
                    return .none
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
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
