//
//  BrandViewModel.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-19.
//

import Foundation
import SwiftUI
import Combine

class ProductViewModel: ObservableObject {
    @Published var itemID: String
    @Published var sources: [String] = []
    @Published var brand: String = ""
    
    @AppStorage private var productInfoData: Data
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(itemID: String) {
        self.itemID = itemID
        self._productInfoData = AppStorage(wrappedValue: Data(), itemID)
        $itemID
            .sink { [self] newItemID in
                self._productInfoData = AppStorage(wrappedValue: Data(), newItemID)
                self.sources = getSources()
                self.brand = getBrand()
            }
            .store(in: &cancellables)
    }
    
    deinit {
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }
    
    private func getSources() -> [String] {
        let decoder = JSONDecoder()
        let productInfo = try? decoder.decode(ProductInfo.self, from: productInfoData)
        let queryResult = productInfo?.sources ?? []
        let filteredResult = queryResult.map{ $0.lowercased() }.filter{ $0.contains(itemID) }
        return filteredResult.sorted { x, y in
            if x.hasSuffix("x.jpg") {
                return true
            }
            if y.hasSuffix("x.jpg") {
                return false
            }
            return x < y
        }
    }
    
    private func getBrand() -> String {
        let decoder = JSONDecoder()
        let productInfo = try? decoder.decode(ProductInfo.self, from: productInfoData)
        return productInfo?.brand ?? "No Brand"
    }
}
