//
//  RatingView.swift
//  Movies
//
//  Created by Alexander Livshits on 15/03/2024.
//

import SwiftUI

struct RatingView: View {
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
    RatingView(rating: 8.5)
}
