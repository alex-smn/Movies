//
//  AppView.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
            MoviesListView(store: store.scope(state: \.moviesTab, action: \.moviesTab))
                .tabItem {
                    Text("Movies")
                }
            
            MoviesListView(store: store.scope(state: \.seriesTab, action: \.seriesTab))
                .tabItem {
                    Text("Series")
                }
            
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}
