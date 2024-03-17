//
//  CastView.swift
//  Movies
//
//  Created by Alexander Livshits on 16/03/2024.
//

import Kingfisher
import SwiftUI

struct CastView: View {
    let cast: Cast
    
    private let imageWidth = 200
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .top) {
            colorScheme == .dark ? Color.gray : Color.white
            
            VStack(alignment: .leading, spacing: 0) {
                if let path = cast.profilePath, let posterUrl = URL(string: "\(Constants.castImageUrlFormat)\(path)") {
                    KFImage(posterUrl)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                } else {
                    Rectangle()
                        .fill(Color(UIColor.lightGray))
                        .aspectRatio(4/5, contentMode: .fit)
                }
                
                Text(cast.name)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                
                Text(cast.character)
                    .fontWeight(.light)
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                
                Spacer()
            }
            .padding(.bottom, 15)
        }
        .frame(width: 160)
        .cornerRadius(10)
        .shadow(radius: 5)
        .multilineTextAlignment(.leading)
    }
}

#Preview {
    CastView(cast: Cast.mock())
}
