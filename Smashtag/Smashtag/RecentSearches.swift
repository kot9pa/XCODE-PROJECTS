//
//  RecentSearches.swift
//  Smashtag
//
//  Created by Konstantin on 25.05.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import Foundation

struct RecentSearches {
    private static let defaults = UserDefaults.standard
    private static let key = "RecentSearces"
    private static let limit = 100
    
    static var searches: [String] {
        return (defaults.object(forKey: key) as? [String]) ?? []
    }
    
    static func add(_ term: String) {
        guard !term.isEmpty else {return}
        var newArray = searches.filter {term.caseInsensitiveCompare($0) != .orderedSame}
        newArray.insert(term, at: 0)
        while newArray.count > limit {
            newArray.removeLast()
        }
        defaults.set(newArray, forKey:key)
    }
    
    static func removeAtIndex(_ index: Int) {
        var currentSearches = (defaults.object(forKey: key) as? [String]) ?? []
        currentSearches.remove(at: index)
        defaults.set(currentSearches, forKey:key)
    }
}
