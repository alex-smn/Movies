//
//  SeriesDetailsView.swift
//  Movies
//
//  Created by Alexander Livshits on 17/03/2024.
//

import Kingfisher
import ComposableArchitecture
import SwiftUI
import AVKit

struct SeriesDetailsView: View {
    let store: StoreOf<SeriesDetailsFeature>
    
    private let castRows = [
        GridItem(.fixed(320), spacing: 15, alignment: .leading)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let series = store.series {
                    ZStack(alignment: .leading) {
                        if let backdropPath = series.backdropPath, let backdropUrl = URL(string: "\(Constants.backdropUrlFormat)\(backdropPath)") {
                            KFImage(backdropUrl)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        }
                        
                        if let posterPath = series.posterPath, let posterUrl = URL(string: "\(Constants.posterUrlFormat)\(posterPath)") {
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
                        HStack {
                            Text(series.name)
                                .font(.title)
                            
                            Spacer()
                            
                            Button {
                                store.send(.toggleFavorite)
                            } label: {
                                Image(systemName: store.isInFavorite ? "heart.fill" : "heart")
                            }
                        }
                        
                        
                        HStack {
                            RatingView(rating: series.voteAverage)
                            
                            Spacer()
                            
                            ForEach(series.genres.prefix(3), id: \.id) { genre in
                                Text(genre.name)
                            }
                        }
                        
                        Text(series.tagline)
                            .multilineTextAlignment(.center)

                            .italic()
                        
                        HStack {
                            Text("Overview")
                                .font(.title2)
                            
                            Spacer()
                        }
                        
                        Text(series.overview)
                            .multilineTextAlignment(.leading)
                            .lineLimit(100)
                        
                        
                        if let videos = store.videos, let trailer = videos.first(where: { $0.type == "Trailer" }) {
                            YouTubeView(videoId: trailer.key)
                                .frame(height: 200)
                        }
                        
                        if let cast = store.castPreview, !cast.isEmpty {
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
                        
                        if let season = series.seasons.first(where: { $0.seasonNumber == series.numberOfSeasons }) {
                            HStack {
                                Text("Last Season")
                                    .font(.title)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Season \(season.seasonNumber)")
                                    .font(.title3)
                                
                                HStack {
                                    HStack(spacing: 3) {
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15)
                                            .padding(.leading, 8)
                                        Text(String(format: "%.1f", season.voteAverage))
                                            .padding(.trailing, 8)
                                    }
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                                    
                                    if let episodeCount = season.episodeCount {
                                        Text("\(episodeCount) Episodes")
                                    }
                                }
                                
                                if !season.overview.isEmpty {
                                    Text(season.overview)
                                        .multilineTextAlignment(.leading)
                                } else {
                                    HStack(spacing: 0) {
                                        Text("Season \(season.seasonNumber) premiered on ")
                                        Text(season.airDate ?? Date.now, style: .date)
                                    }
                                }
                            }
                            .padding()
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray, lineWidth: 1)
                                    .shadow(radius: 5)
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
                                if store.totalReviews > 0 {
                                    NavigationLink {
                                        ReviewsListView(reviews: reviews)
                                    } label: {
                                        Text("View all")
                                    }
                                }
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
                
                if let detailsFetchingError = store.detailsFetchingError {
                    Text(detailsFetchingError)
                }
                if let videosFetchingError = store.videosFetchingError {
                    Text(videosFetchingError)
                }
                if let castFetchingError = store.castFetchingError {
                    Text(castFetchingError)
                }
                if let reviewsFetchingError = store.reviewsFetchingError {
                    Text(reviewsFetchingError)
                }
            }
        }
        .onAppear {
            store.send(.seriesDetailsPageOpened)
        }
    }
}

#Preview {
    SeriesDetailsView(store: Store(initialState: SeriesDetailsFeature.State(seriesId: 278), reducer: {
        SeriesDetailsFeature()
    }))
}
