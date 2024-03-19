//
//  SeriesListView.swift
//  Movies
//
//  Created by Alexander Livshits on 17/03/2024.
//

import ComposableArchitecture
import SwiftUI

struct SeriesListView: View {
    @Bindable var store: StoreOf<SeriesListFeature>
    
    @Environment(\.colorScheme) var colorScheme
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 15, alignment: .top)
    ]
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    VStack {
                        if !store.series.isEmpty {
                            LazyVGrid(columns: columns) {
                                ForEach(Array(store.series.enumerated()), id: \.1.id) { index, series in
                                    NavigationLink(state: SeriesDetailsFeature.State(seriesId: series.id)) {
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
                        
                        if store.isLoading {
                            ProgressView()
                        }
                    }
                }
                .refreshable {
                    store.send(.seriesPageOpened)
                }
                .padding(.top, 60)
                
                menuView
            }
            .clipped()
            .padding(.horizontal, 15)
            .onAppear {
                store.send(.seriesPageOpened)
            }
        } destination: { store in
            SeriesDetailsView(store: store)
        }
    }
    
    private var menuView: some View {
        Menu {
            Button(SeriesListFeature.Sorting.topRated.name) {
                store.send(.sortingSet(.topRated))
            }
            
            Button(SeriesListFeature.Sorting.onTheAir.name) {
                store.send(.sortingSet(.onTheAir))
            }
            
            Button(SeriesListFeature.Sorting.popular.name) {
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
    SeriesListView(store: Store(initialState: SeriesListFeature.State()) {
        SeriesListFeature()
    })
}
