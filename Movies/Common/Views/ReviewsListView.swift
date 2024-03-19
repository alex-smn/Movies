//
//  ReviewsListView.swift
//  Movies
//
//  Created by Alexander Livshits on 19/03/2024.
//

import SwiftUI

struct ReviewsListView: View {
    var reviews: [Review]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(reviews, id: \.id) { review in
                    ReviewView(review: review)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ReviewsListView(reviews: [Review.mock()])
}
