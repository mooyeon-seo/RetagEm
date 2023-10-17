//
//  ProductView.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-13.
//

import SwiftUI
import CoreHaptics

struct ProductView: View {
    // ViewContext passed down from the MakeItEasyApp file as an Environment Variable
    @Environment(\.managedObjectContext) var viewContext
    
    @ObservedObject var product: Product
    
    @State private var showProductDetailView = false
    // Haptics
    @State private var engine: CHHapticEngine?
    @AppStorage("vibration") private var vibration: Bool = true
    
    var body: some View {
        VStack {
            if let xxx = product.xxx, let uiImage = UIImage(data: xxx) {
                Image(uiImage: uiImage)
                    .resizable()
                    .cornerRadius(25.0)
                    .padding()
                    .padding()
                    .frame(height: 400)
                    .onTapGesture(count: 2) {
                        showProductDetailView.toggle()
                    }
                    .onTapGesture {
                        product.completed.toggle()
                        if vibration {
                            if product.completed {
                                simpleSuccess()
                            } else {
                                simpleFailure()
                            }
                        }
                        try? viewContext.save()
                    }
                    .overlay(alignment: .center, content: {
                        Image(systemName: "checkmark.diamond.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .foregroundColor(product.completed ? .green : .clear)
                            .padding()
                            .disabled(true)
                            .allowsTightening(false)
                    })
            } else {
                ProgressView()
                    .scaledToFit()
            }
        }
        .overlay(alignment: .bottom) {
            Text(product.itemID.unwrapped.uppercased())
                .bold()
                .font(.title)
                .foregroundColor(.primary)
                .padding(.bottom)
        }
        .background {
            RoundedRectangle(cornerRadius: 25.0)
                .strokeBorder(product.completed ? .green: .red, lineWidth: 10.0)
                .shadow(color: .primary.opacity(0.5), radius: 2, x: 0, y: 2)
        }
        .sheet(isPresented: $showProductDetailView, content: {
            let productDetailViewModel = ProductDetailViewModel(product: product)
            ProductDetailView(viewModel: productDetailViewModel)
                .environment(\.managedObjectContext, viewContext)
        })
        .task {
            prepareHaptics()
        }
        .onLongPressGesture {
            product.completed.toggle()
            try? viewContext.save()
        }
    }
}

extension ProductView {
    func simpleFailure() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func complexSuccess() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}


struct ProductView_Previews: PreviewProvider {
    
    static var previews: some View {
        let product = Product(context: Persistence.preview.container.viewContext)
        product.itemID = "585"
        product.brand = "blundstone"
        return ProductView(product: product)
    }
    
}
