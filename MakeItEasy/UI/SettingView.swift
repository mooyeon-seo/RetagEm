//
//  SettingView.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-20.
//

import SwiftUI
import CoreData

struct SettingView: View {
    // ViewContext passed down from the MakeItEasyApp file as an Environment Variable
    @Environment(\.managedObjectContext) var viewContext
    // PriceChangeLogManager can parse the json file with product infos
    @StateObject private var priceChangeLogManager = ProductParser()
    @StateObject private var imageAssetsDownloader = ImageAssetsDownloader()
    @State private var showLoadingProductInfos = false
    @State private var showLoadingProductImages = false
    @State private var currentItem = 0
    @State private var currentImage = 0
    @AppStorage("vibration") private var vibration: Bool = true
    
    var body: some View {
        List {
            Button {
                showLoadingProductInfos.toggle()
                Task {
                    await load()
                }
            } label: {
                Label {
                    Text("Load")
                } icon: {
                    Image(systemName: "tray.and.arrow.down.fill")
                }
            }
            
            Toggle(isOn: $vibration) {
                Text("Vibrate when completing a price change")
            }
        }
        .sheet(isPresented: $showLoadingProductInfos) {
            CircularProgress(progress: Double(currentItem) / Double(Constant.totalNumberOfProducts))
                .onReceive(priceChangeLogManager.downloadStatusPublisher) { itemCurrentlyDownloading in
                    currentItem = itemCurrentlyDownloading
                    print(itemCurrentlyDownloading)
                }
        }
    }
    
    private func loadImages() async {
//        await imageAssetsDownloader.downloadImages()
    }
    
    private func load() async {
        await deleteAll(of: "Product")
        await priceChangeLogManager.parseProductObjectFile(forResource: "productInfos", withExtension: "json")
    }
    
    private func deleteAll(of entityName: String) async {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        // Create a batch delete request for the
        // fetch request
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )
        deleteRequest.resultType = .resultTypeObjectIDs

        // Perform the batch delete
        let batchDelete = try? viewContext.execute(deleteRequest)
            as? NSBatchDeleteResult

        guard let deleteResult = batchDelete?.result
            as? [NSManagedObjectID]
            else { return }

        let deletedObjects: [AnyHashable: Any] = [
            NSDeletedObjectsKey: deleteResult
        ]

        // Merge the delete changes into the managed
        // object context
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [viewContext]
        )
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

struct CircularProgress: View {
    @Environment(\.dismiss) var dismiss
    var progress: Double
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 10))
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.linear(duration: 0.5), value: progress)
//                    .animation(.linear(duration: 0.5))
            }
            .padding()
            Button {
                dismiss()
            } label: {
                Text("Download Complete")
                    .foregroundColor(.primary)
            }
            .disabled(progress != 1.0)
            .opacity(progress != 1.0 ? 0.0: 1.0)
        }
    }
}
