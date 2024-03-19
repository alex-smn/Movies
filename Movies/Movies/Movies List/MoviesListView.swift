//
//  MoviesListView.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import ComposableArchitecture
import SwiftUI

struct MoviesListView: View {
    @Bindable var store: StoreOf<MoviesListFeature>
    
    @Environment(\.colorScheme) var colorScheme
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 15, alignment: .top)
    ]
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    VStack {
                        if !store.movies.isEmpty {
                            LazyVGrid(columns: columns) {
                                ForEach(Array(store.movies.enumerated()), id: \.1.id) { index, movie in
                                    NavigationLink(state: MovieDetailsFeature.State(movieId: movie.id)) {
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
                        }
                        
                        if let error = store.fetchingError {
                            Text(error)
                        }
                        
                        if store.isLoading {
                            ProgressView()
                        }
                    }
                }
                .refreshable {
                    store.send(.moviesPageOpened)
                }
                .padding(.top, 60)
                
                menuView
            }
            .clipped()
            .padding(.horizontal, 15)
            .onAppear {
                store.send(.moviesPageOpened)
            }
        } destination: { store in
            MovieDetailsView(store: store)
        }
    }
    
    private var menuView: some View {
        Menu {
            Button(MoviesListFeature.Sorting.topRated.name) {
                store.send(.sortingSet(.topRated))
            }
            
            Button(MoviesListFeature.Sorting.nowPlaying.name) {
                store.send(.sortingSet(.nowPlaying))
            }
            
            Button(MoviesListFeature.Sorting.popular.name) {
                store.send(.sortingSet(.popular))
            }
        } label: {
            Text(store.sorting.name)
            Image(systemName: "chevron.down")
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .foregroundColor(colorScheme == .dark ? .white : .black)
        .background(Color(UIColor.systemBackground))
    }
}

#Preview {
    MoviesListView(store: Store(initialState: MoviesListFeature.State()) {
        MoviesListFeature()
    })
}
