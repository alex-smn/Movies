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
    
    @State private var showingFull = false
    
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
                        .font(.title3)
                    
                    HStack {
                        if let rating = review.authorDetails.rating {
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15)
                                    .padding(.leading, 8)
                                Text(String(format: "%.1f", rating))
                                    .padding(.trailing, 8)
                            }
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        }
                        
                        Text("Written by \(review.author)")
                            .fontWeight(.light)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(review.content)
                    .multilineTextAlignment(.leading)
                    .lineLimit(showingFull || review.content.count < 300 ? nil : 8)
                if review.content.count > 300 {
                    Button {
                        showingFull.toggle()
                    } label: {
                        Text(showingFull ? "show less" : "show more")
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
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
