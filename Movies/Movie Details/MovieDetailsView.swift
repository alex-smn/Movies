//
//  MovieDetailsView.swift
//  Movies
//
//  Created by Alexander Livshits on 15/03/2024.
//

import Kingfisher
import ComposableArchitecture
import SwiftUI
import AVKit

struct MovieDetailsView: View {
    let store: StoreOf<MovieDetailsFeature>
    
    private let castRows = [
        GridItem(.fixed(320), spacing: 15, alignment: .leading)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let movie = store.movie {
                    ZStack(alignment: .leading) {
                        if let backdropUrl = URL(string: "\(Constants.backdropUrlFormat)\(movie.backdropPath)") {
                            KFImage(backdropUrl)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        }
                        
                        if let posterUrl = URL(string: "\(Constants.posterUrlFormat)\(movie.posterPath)") {
                            KFImage(posterUrl)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 80)
                                .cornerRadius(5)
                                .padding(.leading, 10)
                            
                        } else {
                            Rectangle()
                                .fill(Color(UIColor.lightGray))
                                .aspectRatio(2/3, contentMode: .fit)
                        }
                    }
                    .frame(height: 220)
                    
                    VStack(spacing: 20) {
                        Text(movie.title)
                            .font(.title)
                        
                        
                        HStack {
                            RatingView(rating: movie.voteAverage)
                            Spacer()
                            ForEach(movie.genres, id: \.id) { genre in
                                Text(genre.name)
                            }
                        }
                        
                        Text(movie.tagline)
                            .italic()
                        
                        HStack {
                            Text("Overview")
                                .font(.title2)
                            
                            Spacer()
                        }
                        
                        Text(movie.overview)
                            .multilineTextAlignment(.leading)
                            .lineLimit(100)
                        
                        
                        if let videos = store.videos, let trailer = videos.first(where: { $0.type == "Trailer" }) {
                            YouTubeView(videoId: trailer.key)
                                .frame(height: 200)
                                
                        }
                        
                        if let cast = store.castPreview {
                            HStack {
                                Text("Top Billed cast")
                                    .font(.title)
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: castRows) {
                                    ForEach(cast, id: \.id) { actor in
                                        CastView(cast: actor)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                            }
                        }
                        
                        if let reviews = store.reviewsPreview {
                            HStack {
                                Text("Reviews")
                                    .font(.title)
                                Text("\(store.totalReviews)")
                                    .font(.title)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                            }
                            if !reviews.isEmpty {
                                ReviewView(review: reviews[0])
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                
                if store.isLoading {
                    ProgressView()
                }
                
                if store.hasDetailsFetchingError {
                    Text("Error fetching movie details")
                }
                if store.hasVideosFetchingError {
                    Text("Error fetching movie trailer")
                }
                if store.hasCastFetchingError {
                    Text("Error fetching movie cast")
                }
                if store.hasReviewsFetchingError {
                    Text("Error fetching movie reviews")
                }
            }
        }
        .multilineTextAlignment(.center)
        .onAppear {
            store.send(.movieDetailsPageOpened)
        }
    }
}

#Preview {
    MovieDetailsView(store: Store(initialState: MovieDetailsFeature.State(movieId: 278), reducer: {
        MovieDetailsFeature()
    }))
}
