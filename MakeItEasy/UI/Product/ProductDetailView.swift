//
//  ProductDetailView.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-13.
//

import SwiftUI
import CoreData

class ProductDetailViewModel: ObservableObject {
    @Published var product: Product
    @Published var itemID: String
    
    let encoder: JSONEncoder = JSONEncoder()
    let decoder: JSONDecoder = JSONDecoder()
    
    var sources: [String] {
        if let data = product.sources, let result = try? decoder.decode([String].self, from: data) {
            return result.sorted { lhs, rhs in
                if lhs.hasSuffix("XXX.jpg") {
                    return true
                } else if rhs.hasSuffix("XXX.jpg") {
                    return false
                }
                return lhs < rhs
            }
        }
        return []
    }
    
    var imageDatas: [Data] {
        [product.xxx, product.xx2, product.xx3, product.xx4, product.xx5, product.xx6].compactMap{ $0 }
    }
    
    init(product: Product) {
        self.product = product
        self.itemID = product.itemID.unwrapped
    }
}

struct ProductDetailView: View {
    @Environment(\.managedObjectContext) var viewContext
    @StateObject var viewModel: ProductDetailViewModel
        
    var body: some View {
        VStack {
            TabView {
                ForEach(viewModel.sources, id: \.self) { source in
                    AsyncImage(url: URL(string: source)) { image in
                        image
                            .resizable()
                            .cornerRadius(25.0)
                            .padding()
                            .frame(height: 350)
                    } placeholder: {
                        ProgressView()
                    }
                }
            }
            Text(viewModel.itemID)
                .bold()
                .font(.largeTitle)
                .padding()
        }
        .tabViewStyle(.page)
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let product = Product(context: Persistence.preview.container.viewContext)
        product.itemID = "585"
        product.brand = "blundstone"
        let productDetailViewModel = ProductDetailViewModel(product: product)
        return ProductDetailView(viewModel: productDetailViewModel)
    }
}
