//
//  Array+Extenstions.swift
//  Movies
//
//  Created by Alexander Livshits on 15/03/2024.
//

import Foundation

extension Array where Element == Movie {
    func uniqued() -> [Movie] {
        var seen = Set<Int>()
        return filter { seen.insert($0.id).inserted }
    }
}
