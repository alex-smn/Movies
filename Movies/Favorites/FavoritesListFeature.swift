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
        case requestToken
        case tokenGenerated(Result<RequestToken, Error>)
        case authenticate
        case authenticated(Result<Bool, Error>)
        case createSessionId
        case sessionIdCreated(Result<Session, Error>)
        case getAccountDetails
        case accountDetailsFetched(Result<Account, Error>)
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
                state.isLoading = false
                state.fetchingError = nil
                
                if state.accountId != nil {
                    return .run { send in
                        await send(.fetchFavorites)
                    }
                } else {
                    return .run { send in
                        await send(.requestToken)
                    }
                }
                
            case .listEndReached:
                state.page += 1
                
                return .run { send in
                    await send(.fetchFavorites)
                }
                
            case let .filterSet(filter):
                state.page = 1
                state.movies = []
                state.series = []
                state.filter = filter
                
                return .run { send in
                    await send(.fetchFavorites)
                }
                
            case .requestToken:
                state.isLoading = true
                
                return .run { send in
                    await send(
                        .tokenGenerated(
                            Result {
                                try await self.favoritesListClient.requestToken()
                            }
                        )
                    )
                }
                
            case let .tokenGenerated(.success(result)):
                state.isLoading = false
                state.hasAuthenticationError = false
                state.token = result.requestToken
                
                return .run { send in
                    await send(.authenticate)
                }
                
            case .tokenGenerated(.failure):
                state.isLoading = false
                state.hasAuthenticationError = true
                
                return .none
                
            case .authenticate:
                state.isLoading = true
                
                if let token = state.token {
                    return .run { [token = token] send in
                        await send(
                            .authenticated(
                                Result {
                                    try await self.favoritesListClient.authenticate(token: token)
                                }
                            )
                        )
                    }
                } else {
                    return .none
                }
                
            case let .authenticated(.success(result)):
                state.isLoading = false
                
                if result == true {
                    return .run { send in
                        await send(.createSessionId)
                    }
                } else {
                    state.hasAuthenticationError = true
                    return .none
                }
                
            case .authenticated(.failure):
                state.isLoading = false
                state.hasAuthenticationError = true
                
                return .none
                
            case .createSessionId:
                state.isLoading = true
                
                if let token = state.token {
                    return .run { [token = token] send in
                        await send(
                            .sessionIdCreated(
                                Result {
                                    try await self.favoritesListClient.createSessionId(token: token)
                                }
                            )
                        )
                    }
                } else {
                    return .none
                }
                
            case let .sessionIdCreated(.success(result)):
                state.isLoading = false
                state.sessionId = result.sessionId
                
                return .run { send in
                    await send(.getAccountDetails)
                }
                
            case .sessionIdCreated(.failure):
                state.isLoading = false
                state.hasAuthenticationError = true
                
                return .none
                
            case .getAccountDetails:
                state.isLoading = true
                
                if let sessionId = state.sessionId {
                    return .run { [sessionId = sessionId] send in
                        await send(
                            .accountDetailsFetched(
                                Result {
                                    try await self.favoritesListClient.getAccountDetails(sessionId: sessionId)
                                }
                            )
                        )
                    }
                } else {
                    return .none
                }
                
            case let .accountDetailsFetched(.success(result)):
                state.isLoading = false
                state.accountId = result.id
                
                return .run { send in
                    await send(.fetchFavorites)
                }
                
            case .accountDetailsFetched(.failure):
                state.isLoading = false
                state.hasAuthenticationError = true
                
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
//
//@Reducer
//enum Shared {
//    @ObservableState
//    struct State: Equatable {
//        var accountId: Int?
//    }
//    
//    enum Action {
//        case setAccountId(Int)
//    }
//    
//    var body: some ReducerOf<Self> {
//        Reduce { state, action in
//            switch action {
//            case let .setAccountId(id):
//                state.accountId = id
//                
//                return .none
//            }
//        }
//    }
//}
