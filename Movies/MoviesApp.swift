//
//  MoviesApp.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import SwiftUI
import ComposableArchitecture
import XCTestDynamicOverlay

@main
struct MoviesApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                AppView(store: MoviesApp.store)
            }
        }
    }
}
