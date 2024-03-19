//
//  Array+Extenstions.swift
//  Movies
//
//  Created by Alexander Livshits on 15/03/2024.
//

import Foundation

extension Array where Element: Identifiable {
    func uniqued() -> [Element] {
        var seen = Set<Element.ID>()
        return filter { seen.insert($0.id).inserted }
    }
}
