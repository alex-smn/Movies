//
//  AppFeature.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import ComposableArchitecture

@Reducer
struct AppFeature {
    struct State {
        var moviesTab = MoviesListFeature.State()
        var seriesTab = SeriesListFeature.State()
        var favoritesTab = FavoritesListFeature.State()
    }
    
    enum Action {
        case moviesTab(MoviesListFeature.Action)
        case seriesTab(SeriesListFeature.Action)
        case favoritesTab(FavoritesListFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.moviesTab, action: \.moviesTab) {
            MoviesListFeature()
        }
        
        Scope(state: \.seriesTab, action: \.seriesTab) {
            SeriesListFeature()
        }
        
        Scope(state: \.favoritesTab, action: \.favoritesTab) {
            FavoritesListFeature()
        }
        
        Reduce { state, action in
            return .none
        }
    }
}
