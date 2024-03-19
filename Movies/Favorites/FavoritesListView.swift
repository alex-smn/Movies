//
//  FavoritesListView.swift
//  Movies
//
//  Created by Alexander Livshits on 17/03/2024.
//

import ComposableArchitecture
import SwiftUI

struct FavoritesListView: View {
    @Bindable var store: StoreOf<FavoritesListFeature>
    
    @Environment(\.colorScheme) var colorScheme
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 15, alignment: .top)
    ]
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    VStack {
                        if store.accountId == nil {
                            Button {
                                store.send(.authorize)
                            } label: {
                                Text("Log in")
                            }
                        } else {
                            if store.filter == .movies, !store.movies.isEmpty {
                                LazyVGrid(columns: columns) {
                                    ForEach(Array(store.movies.enumerated()), id: \.1.id) { index, movie in
                                        NavigationLink(
                                            state: FavoritesListFeature.Path.State.movie( MovieDetailsFeature.State(movieId: movie.id))
                                        ) {
                                            MoviesListItemView(movie: movie)
                                                .onAppear {
                                                    if store.movies.count - 2 == index {
                                                        store.send(.listEndReached)
                                                    }
                                                }
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            } else if store.filter == .series, !store.series.isEmpty {
                                LazyVGrid(columns: columns) {
                                    ForEach(Array(store.series.enumerated()), id: \.1.id) { index, series in
                                        NavigationLink(
                                            state: FavoritesListFeature.Path.State.series(SeriesDetailsFeature.State(seriesId: series.id))
                                        ) {
                                            SeriesListItemView(series: series)
                                                .onAppear {
                                                    if store.series.count - 2 == index {
                                                        store.send(.listEndReached)
                                                    }
                                                }
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            }
                            
                            if let error = store.fetchingError {
                                Text(error)
                            }
                            
                            if store.hasAuthenticationError {
                                Text("Error: authorization error")
                            }
                            
                            if store.isLoading {
                                ProgressView()
                            }
                        }
                    }
                }
                .refreshable {
                    store.send(.favoritesPageOpened)
                }
                .padding(.top, 60)
                
                ZStack {
                    Menu {
                        Button(FavoritesListFeature.Filter.movies.name) {
                            store.send(.filterSet(.movies))
                        }
                        
                        Button(FavoritesListFeature.Filter.series.name) {
                            store.send(.filterSet(.series))
                        }
                    } label: {
                        Text(store.filter.name)
                        Image(systemName: "chevron.down")
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .background(Color(UIColor.systemBackground))
                    
                    HStack {
                        Spacer()
                        
                        if store.accountId != nil {
                            Button {
                                store.send(.logOut)
                            } label: {
                                Text("Log out")
                            }
                        }
                    }
                }
            }
            .clipped()
            .padding(.horizontal, 15)
            .onAppear {
                store.send(.favoritesPageOpened)
            }
        } destination: { store in
            switch store.case {
            case let .movie(store):
                MovieDetailsView(store: store)
            case let .series(store):
                SeriesDetailsView(store: store)
            }
        }
    }
}

#Preview {
    FavoritesListView(store: Store(initialState: FavoritesListFeature.State()) {
        FavoritesListFeature()
    })
}
