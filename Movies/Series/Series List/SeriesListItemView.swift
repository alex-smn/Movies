//
//  SeriesListItemView.swift
//  Movies
//
//  Created by Alexander Livshits on 17/03/2024.
//

import Kingfisher
import SwiftUI

struct SeriesListItemView: View {
    let series: SeriesListItem
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            colorScheme == .dark ? Color.gray : Color.white
            
            VStack(alignment: .leading, spacing: 0) {
                if let path = series.posterPath, let posterUrl = URL(string: "\(Constants.posterUrlFormat)\(path)") {
                    KFImage(posterUrl)
                        .resizable()
                        .scaledToFit()
                } else {
                    Rectangle()
                        .fill(Color(UIColor.lightGray))
                        .aspectRatio(2/3, contentMode: .fit)
                }
                
                RatingView(rating: series.voteAverage)
                    .padding(.top, -20)
                
                Text(series.name)
                    .lineLimit(2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                
                if let firstAirDate = series.firstAirDate {
                    Text(firstAirDate, style: .date)
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
    return SeriesListItemView(series: SeriesListItem.mock(id: 2))
}

