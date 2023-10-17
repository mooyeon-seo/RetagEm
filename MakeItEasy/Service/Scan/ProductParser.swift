//
//  ChangeTagManager.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-13.
//
import Foundation
import OSLog
import CoreData
import Combine

class ProductParser: ObservableObject {
    private let logger: Logger = Logger(subsystem: "com.devil.red.MakeItEasy", category: "PriceChangeLogManager")
    @Published var currentItem = 0
    
    let encoder = JSONEncoder()
    
    var downloadStatusPublisher: AnyPublisher<Int, Never> {
        $currentItem
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func parseProductObjectFile(forResource name: String, withExtension ext: String) async {
        guard let fileURL = Bundle(for: type(of: self)).url(forResource: name, withExtension: ext) else { return }
        guard let data = try? Data(contentsOf: fileURL) else { return }
        guard let products = try? JSONDecoder().decode([ProductInfo].self, from: data) else { return }
        
        var productIterator = products.makeIterator()
        DispatchQueue.main.async {
            self.currentItem = 0
        }
        
        await Persistence.shared.container.performBackgroundTask { context in
            let insertRequest = NSBatchInsertRequest(entity: Product.entity()) { (object: NSManagedObject) in
                guard let nextProduct = productIterator.next() else { return true }
                let itemID = nextProduct.itemID.uppercased()
                if let product = object as? Product {
                    // save itemID in upper case
                    product.itemID = itemID
                    product.brand = nextProduct.brand
                    let sources = nextProduct.sources.filter{ $0.uppercased().contains(itemID) }
                    product.sources = try? self.encoder.encode(sources)
                    if let xxx = sources.first, let imageURL = URL(string: xxx) {
                        product.xxx = try? Data(contentsOf: imageURL)
                    }                    
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.currentItem += 1
                }
                return false
            }
            insertRequest.resultType = .objectIDs
            let batchInsert = try? context.execute(insertRequest) as? NSBatchInsertResult
            guard let insertResult = batchInsert?.result as? [NSManagedObjectID] else { return }
            let createdObjects: [AnyHashable: Any] = [NSInsertedObjectsKey: insertResult]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: createdObjects, into: [context])
            UserDefaults.standard.set(true, forKey: "LoadingComplete")
        }
    }
}
