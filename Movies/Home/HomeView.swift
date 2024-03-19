//
//  HomeView.swift
//  Movies
//
//  Created by Alexander Livshits on 18/03/2024.
//

import ComposableArchitecture
import Kingfisher
import SwiftUI

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    @State private var selectedSearchFilter: HomeFeature.SearchFilter = .movies
    @State private var selectedPeriod: HomeFeature.Period = .day

    @Environment(\.colorScheme) var colorScheme

    private let trendingRows = [
        GridItem(.fixed(400), spacing: 15, alignment: .leading)
    ]
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("Search", text: $store.searchQuery.sending(\.searchQueryChanged))
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    if store.searchQuery.isEmpty {
                        if !store.trending.isEmpty {
                            trendingView
                        }
                    } else {
                        searchView
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .onAppear {
                store.send(.homePageOpened)
            }
        } destination: { store in
            switch store.case {
            case let .movie(store):
                MovieDetailsView(store: store)
            case let .series(store):
                SeriesDetailsView(store: store)
            }
        }
        .task(id: store.searchQuery) {
            do {
                try await Task.sleep(for: .milliseconds(300))
                await store.send(.searchQueryChangedDebounced).finish()
            } catch {
                // TODO: implement
            }
        }
    }
    
    private var searchView: some View {
        VStack(alignment: .leading) {
            if !store.searchQuery.isEmpty {
                Picker("", selection: $selectedSearchFilter) {
                    Text("Movies").tag(HomeFeature.SearchFilter.movies)
                    Text("People").tag(HomeFeature.SearchFilter.person)
                    Text("TV Shows").tag(HomeFeature.SearchFilter.series)
                }
                .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading) {
                switch store.searchFilter {
                case .movies:
                    ForEach(store.searchMoviesResults) { movie in
                        NavigationLink(
                            state: HomeFeature.Path.State.movie(MovieDetailsFeature.State(movieId: movie.id))
                        ) {
                            searchResultView(path: movie.posterPath, title: movie.title, overview: movie.overview)
                        }
                    }
                case .series:
                    ForEach(store.searchSeriesResults) { series in
                        NavigationLink(
                            state: HomeFeature.Path.State.series(SeriesDetailsFeature.State(seriesId: series.id))
                        ) {
                            searchResultView(path: series.posterPath, title: series.name, overview: series.overview)
                        }
                    }
                case .person:
                    ForEach(store.searchPersonsResults) { person in
                        searchResultView(path: person.profilePath, title: person.name, overview: person.knownForDepartment)
                    }
                }
            }
        }
        .onChange(of: selectedSearchFilter) { _, newValue in
            store.send(.searchFilterChanged(newValue))
        }
    }
    
    private func searchResultView(path: String?, title: String, overview: String) -> some View {
        HStack {
            if let path, let posterUrl = URL(string: "\(Constants.posterUrlFormat)\(path)") {
                KFImage(posterUrl)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
            } else {
                Rectangle()
                    .fill(Color(UIColor.lightGray))
                    .aspectRatio(2/3, contentMode: .fit)
                    .frame(width: 80)
            }
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                                    
                Text(overview)
                    .lineLimit(2)
                    .font(.system(size: 14))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
    }
    
    private var periodPickerView: some View {
        Picker("", selection: $selectedPeriod) {
            Text("Today").tag(HomeFeature.Period.day)
            Text("This Week").tag(HomeFeature.Period.week)
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedPeriod) { _, newValue in
            store.send(.periodChanged(newValue))
        }
    }
    
    private var trendingView: some View {
        VStack(alignment: .leading) {
            Text("Trending")
                .font(.title)
            
            periodPickerView
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: trendingRows) {
                    ForEach(Array(store.trending.enumerated()), id: \.1.id) { index, program in
                        if let movie = program.toMoviesListItem() {
                            NavigationLink(
                                state: HomeFeature.Path.State.movie(MovieDetailsFeature.State(movieId: movie.id))
                            ) {
                                MoviesListItemView(movie: movie)
                                    .frame(width: 180)
                                    .onAppear {
                                        if store.trending.count - 2 == index {
                                            store.send(.listEndReached)
                                        }
                                    }
                            }
                        } else if let series = program.toSeriesListItem() {
                            NavigationLink(
                                state: HomeFeature.Path.State.series(SeriesDetailsFeature.State(seriesId: series.id))
                            ) {
                                SeriesListItemView(series: series)
                                    .frame(width: 180)
                                    .onAppear {
                                        if store.trending.count - 2 == index {
                                            store.send(.listEndReached)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(store: Store(initialState: HomeFeature.State(), reducer: {
        HomeFeature()
    }))
}
