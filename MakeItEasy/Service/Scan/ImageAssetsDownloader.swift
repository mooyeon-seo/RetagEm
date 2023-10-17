//
//  ImageAssetsDownloader.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-27.
//

import Foundation
import CoreData
import Combine

class ImageAssetsDownloader: ObservableObject {
    @Published var downloadStatus: Int = 0
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    var downloadStatusPublisher: AnyPublisher<Int, Never> {
        $downloadStatus
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
//    
//    func downloadImages() async {
//        await Persistence.shared.container.performBackgroundTask{ async context in
//            let fetchRequest = Product.fetchRequest()
//            guard let products = try? context.fetch(fetchRequest) else { return }
//            
//            for product in products {
//                DispatchQueue.main.async {
//                    self.downloadStatus += 1
//                }
//                
//                if let data = product.sources, let result = try? decoder.decode([String].self, from: data) {
//                    let sources = result.sorted { lhs, rhs in
//                        if lhs.hasSuffix("XXX.jpg") {
//                            return true
//                        } else if rhs.hasSuffix("XXX.jpg") {
//                            return false
//                        }
//                        return lhs < rhs
//                    }
//                    
//                    async let images = sources.map { source in source.imageData }
//                    
//                    product.xxx = images[0]
//                    product.xx2 = images[1]
//                    product.xx3 = images[2]
//                    product.xx4 = images[3]
//                    product.xx5 = images[4]
//                    product.xx6 = images[5]
//                }
//            }
//        })
//    }
}

extension String {
    var imageData: Data? {
        get async {
            guard  let imageURL = URL(string: self) else { return nil }
            return try? Data(contentsOf: imageURL)
        }
    }
}
