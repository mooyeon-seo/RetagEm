//
//  ContentView.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-13.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var priceChangeLogManager = ProductParser()
    
    var body: some View {
        PriceChangeLogView()
            .environmentObject(priceChangeLogManager)
            .tabItem {
                Image(systemName: "tag.circle.fill")
                    .renderingMode(.template)

            }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, Persistence.preview.container.viewContext)
    }
}
