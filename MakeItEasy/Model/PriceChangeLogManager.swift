//
//  ChangeTagManager.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-13.
//
import Foundation
import Combine
import OSLog

class PriceChangeLogManager: ObservableObject {
    private let logger: Logger = Logger(subsystem: "com.devil.red.MakeItEasy", category: "PriceChangeLogManager")
    private var cancellables: Set<AnyCancellable> = []
    
    var document = Scanner()
        
    func parseProductObjectFile(forResource name: String, withExtension ext: String) async {
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: name, withExtension: ext) else { return }
        guard let data = try? Data(contentsOf: fileURL) else { return }
        guard let products = try? JSONDecoder().decode([Product].self, from: data) else { return }
        
        var itemIDs: [String] = []
        
        for product in products {
            if let productInfo = try? JSONEncoder().encode(ProductInfo(brand: product.brand, sources: product.sources)) {
                let itemID = product.itemID.uppercased()
                UserDefaults.standard.set(productInfo, forKey: itemID)
                itemIDs.append(itemID)
            }
        }
        UserDefaults.standard.set(itemIDs, forKey: "itemIDs")
        UserDefaults.standard.set(true, forKey: "LoadingComplete")        
    }
}
