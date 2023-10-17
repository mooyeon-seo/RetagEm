//
//  ImagesView.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-25.
//

import SwiftUI
import CoreData

struct ImagesView: View {
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
        NavigationView {
//            List {
//                ForEach(images) { productImage in
//                        AsyncImage(url: URL(string: productImage.source.unwrapped)) { image in
//                            image
//                                .resizable()
//                                .cornerRadius(15.0)
//                                .scaledToFit()
//                                .frame(width: 350, height: 350)
//                        } placeholder: {
//                            ProgressView()
//                        }
//                }
//            }
//            .navigationTitle("\(images.count)")
        }
    }
}

struct ImagesView_Previews: PreviewProvider {
    static var previews: some View {
        ImagesView()
            .environment(\.managedObjectContext, Persistence.preview.container.viewContext)
    }
}
