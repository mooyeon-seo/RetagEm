//
//  PriceChangeLogView.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-13.
//

import SwiftUI
import Combine

struct PriceChangeLogView: View {
    // ViewContext passed down from the MakeItEasyApp file as an Environment Variable
    @Environment(\.managedObjectContext) var viewContext
    @SectionedFetchRequest<Optional<String>, Product>(
        sectionIdentifier: \.brand,
        sortDescriptors: [SortDescriptor(\.brand)]
    )
    private var products: SectionedFetchResults<Optional<String>, Product>
    @StateObject var levenshtein = Levenshtein()
    
    @StateObject var scanner = Scanner()
    @State private var showDocumentScannerView = false
    @State private var loading = false
    
    @State private var current = 0
        
    var body: some View {
        VStack {
            if loading && current < scanner.scannedItemIDs.count {
                CircularProgress(progress: Double(current) / Double(scanner.scannedItemIDs.count))
            } else {
                ScrollView {
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        ForEach(products) { section in
                            Section(header: Text(section.id.unwrapped).bold().font(.largeTitle)) {
                                ForEach(section) { product in
                                    ProductView(product: product)
                                        .environment(\.managedObjectContext, viewContext)
                                        .padding()
                                }
                            }
                            .headerProminence(.increased)
                        }
                    }
                }
            }   
        }
        .overlay(alignment: .topTrailing) {
            if !loading || !(current < scanner.scannedItemIDs.count) {
                Button {
                    showDocumentScannerView.toggle()
                } label: {
                    Image(systemName: "barcode.viewfinder")
                        .renderingMode(.template)
                        .font(.largeTitle)
                        .padding()
                        .foregroundColor(.primary)
                }
                .disabled(!levenshtein.isDoneLoadingAllItems)
            }
        }
        .sheet(isPresented: $showDocumentScannerView, onDismiss: {
            self.loading = true
        }, content: {
            ScanViewController()
                .environmentObject(scanner)
        })
        .onChange(of: scanner.scannedItemIDs, perform: { newItems in
            DispatchQueue.global().async {
                self.current = 0
                let updatedItems = newItems.compactMap{
                    DispatchQueue.main.async {
                        current += 1
                    }
                    return levenshtein.closestString(to: $0, in: levenshtein.items)
                }
                DispatchQueue.main.async {
                    self.products.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                        NSPredicate(format: "itemID in %@", updatedItems)
                    ])
                    self.loading = false
                }
            }
        })
        .task {
            await levenshtein.getAllItems()
        }
    }
}
// return self ?? ""
extension Optional<String> {
    var unwrapped: String {
        return self ?? ""
    }
}

