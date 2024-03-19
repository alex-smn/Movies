//
//  MoviesListItemView.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import Kingfisher
import SwiftUI

struct MoviesListItemView: View {
    let movie: MoviesListItem
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            colorScheme == .dark ? Color.gray : Color.white
            
            VStack(alignment: .leading, spacing: 0) {
                if let posterUrl = URL(string: "\(Constants.posterUrlFormat)\(movie.posterPath)") {
                    KFImage(posterUrl)
                        .resizable()
                        .scaledToFit()
                } else {
                    Rectangle()
                        .fill(Color(UIColor.lightGray))
                        .aspectRatio(2/3, contentMode: .fit)
                }
                
                RatingView(rating: movie.voteAverage)
                    .padding(.top, -20)
                
                Text(movie.title)
                    .lineLimit(2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                
                if let releaseDate = movie.releaseDate {
                    Text(releaseDate, style: .date)
                        .fontWeight(.light)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                    
                }
                Spacer()
            }
            .padding(.bottom, 15)
        }
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    return MoviesListItemView(movie: MoviesListItem.mock(id: 2))
}

