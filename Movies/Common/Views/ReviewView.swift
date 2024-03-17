//
//  ReviewView.swift
//  Movies
//
//  Created by Alexander Livshits on 16/03/2024.
//

import Kingfisher
import SwiftUI

struct ReviewView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 20) {
                if
                    let path = review.authorDetails.avatarPath,
                        !path.isEmpty,
                        let url = URL(string: "\(Constants.reviewAuthorImageUrlFormat)\(path)")
                {
                    KFImage(url)
                        .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .fill(.gray)
                            .frame(width: 70)
                        Text(review.author.prefix(1).uppercased())
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("A review by \(review.author)")
                        .font(.title2)
                    
                    HStack {
                        if let rating = review.authorDetails.rating {
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15)
                                Text("\(rating)")
                            }
                            .frame(width: 45)
                            .background(.blue)
                            .cornerRadius(5)
                        }
                        
                        Text("Written by \(review.author)")
                            .fontWeight(.light)
                    }
                }
            }
            
            Text(review.content)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 5)
                .stroke(.gray, lineWidth: 1)
                .shadow(radius: 5)
        }
        
        
    }
}

#Preview {
    ReviewView(review: Review.mock())
}
