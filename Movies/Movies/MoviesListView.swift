//
//  MoviesListView.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import ComposableArchitecture
import SwiftUI

struct MoviesListView: View {
    let store: StoreOf<MoviesListFeature>
    
    @Environment(\.colorScheme) var colorScheme
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 15, alignment: .top)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack {
                    if !store.movies.isEmpty {
                        LazyVGrid(columns: columns) {
                            ForEach(Array(store.movies.enumerated()), id: \.1.id) { index, movie in
                                MoviesListItemView(movie: movie)
                                    .onAppear {
                                        if store.movies.count - 2 == index {
                                            store.send(.listEndReached)
                                        }
                                    }
                            }
                        }
                        .padding(.top, 10)
                    }
                    
                    if store.hasFetchingError {
                        Text("Error: can't fetch movies")
                    }
                    
                    if store.isLoading {
                        ProgressView()
                    }
                }
            }
            .padding(.top, 60)
            
            Menu {
                Button("Top rated") {
                    store.send(.sortingSet(.topRated))
                }
                
                Button("Now playing") {
                    store.send(.sortingSet(.nowPlaying))
                }
                
                Button("Popular") {
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
        .clipped()
        .padding(.horizontal, 15)
        .onAppear {
            store.send(.moviesPageOpened)
        }
    }
}

#Preview {
    MoviesListView(store: Store(initialState: MoviesListFeature.State()) {
        MoviesListFeature()
    })
}
