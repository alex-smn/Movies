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
        var seriesTab = MoviesListFeature.State()
    }
    
    enum Action {
        case moviesTab(MoviesListFeature.Action)
        case seriesTab(MoviesListFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.moviesTab, action: \.moviesTab) {
            MoviesListFeature()
        }
        
        Scope(state: \.seriesTab, action: \.seriesTab) {
            MoviesListFeature()
        }
        
        Reduce { state, action in
            return .none
        }
    }
}
