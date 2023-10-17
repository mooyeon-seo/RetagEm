//
//  Levenshtein.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-20.
//

import Foundation
class Levenshtein: ObservableObject {
    @Published private(set) var items: [String] = []
    @Published private(set) var isDoneLoadingAllItems: Bool = false
    
    func getAllItems() async {
        await Persistence.shared.container.performBackgroundTask { context in
            let fetchRequest = Product.fetchRequest()
            let context = Persistence.shared.container.viewContext
            guard let products = try? context.fetch(fetchRequest) else { return }
            DispatchQueue.main.async {
                self.items = products.compactMap{ $0.itemID?.uppercased() }
                self.isDoneLoadingAllItems = true
            }
        }
    }
    
    func distance(_ str1: String, _ str2: String) -> Int {
        let m = str1.count
        let n = str2.count
        
        if m == 0 {
            return n
        }
        
        if n == 0 {
            return m
        }
        
        var distanceMatrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m {
            distanceMatrix[i][0] = i
        }
        
        for j in 0...n {
            distanceMatrix[0][j] = j
        }
        
        for i in 1...m {
            let str1Index = str1.index(str1.startIndex, offsetBy: i - 1)
            
            for j in 1...n {
                let str2Index = str2.index(str2.startIndex, offsetBy: j - 1)
                
                if str1[str1Index] == str2[str2Index] {
                    distanceMatrix[i][j] = distanceMatrix[i - 1][j - 1]
                } else {
                    distanceMatrix[i][j] = min(
                        distanceMatrix[i - 1][j] + 1,
                        distanceMatrix[i][j - 1] + 1,
                        distanceMatrix[i - 1][j - 1] + 1
                    )
                }
            }
        }
        
        return distanceMatrix[m][n]
    }

    func closestString(to x: String, in array: [String]) -> String? {
        while !isDoneLoadingAllItems {
            sleep(1)
        }
        var closestString: String?
        var minDistance = Int.max
        
        for string in array {
            let distance = distance(x, string)
            
            if distance < minDistance {
                minDistance = distance
                closestString = string
            }
        }
        return closestString
    }
}
