//
//  MoviesListItemView.swift
//  Movies
//
//  Created by Alexander Livshits on 14/03/2024.
//

import Kingfisher
import SwiftUI

struct MoviesListItemView: View {
    let movie: Movie
    private let imageWidth = 200
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            colorScheme == .dark ? Color.gray : Color.white
            
            VStack(alignment: .leading, spacing: 0) {
                if let posterUrl = URL(string: "\(Constants.posterUrlFormat)\(imageWidth)\(movie.posterPath)") {
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
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                
                Text(movie.releaseDate, style: .date)
                    .fontWeight(.light)
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
            }
            .padding(.bottom, 15)
        }
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

private struct RatingView: View {
    let rating: Float
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.black)
                .frame(width: 40, height: 40)
            
            Circle()
                .trim(from: 0, to: CGFloat(rating * 0.1))
                .stroke(
                    rating < 5 ? .red : rating < 7 ? .yellow : .green,
                    lineWidth: 3
                )
               .frame(width: 35, height: 35)
               .rotationEffect(.degrees(-90))
            
            Text("\(Int(rating * 10))")
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.leading, 10)
    }
}

#Preview {
    return MoviesListItemView(movie: Movie.mock(id: 2))
}

