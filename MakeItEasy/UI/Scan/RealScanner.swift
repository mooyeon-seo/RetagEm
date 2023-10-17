//
//  RealScanner.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-19.
//

import SwiftUI
import UIKit
import VisionKit
struct CameraScannerViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let viewController =  DataScannerViewController(recognizedDataTypes: [.text()],qualityLevel: .fast,recognizesMultipleItems: false, isHighFrameRateTrackingEnabled: false, isHighlightingEnabled: true)
        return viewController
    }
    func updateUIViewController(_ viewController: DataScannerViewController, context: Context) {}
}

struct RealScanner: View {
    @State private var scanResults: String = ""
    @State private var showDeviceNotCapacityAlert = false
    @State private var showCameraScannerView = false
    @State private var isDeviceCapacity = false
    
    var body: some View {
        VStack {
            Text(scanResults)
                .padding()
            Button {
                if isDeviceCapacity {
                    self.showCameraScannerView = true
                } else {
                    self.showDeviceNotCapacityAlert = true
                }
            } label: {
                Text("Tap to Scan Documents")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .alert("Scanner Unavailable", isPresented: $showDeviceNotCapacityAlert, actions: {})
        .sheet(isPresented: $showCameraScannerView) {
            // Present the scanning view
        }
        onAppear {
            isDeviceCapacity = (DataScannerViewController.isSupported && DataScannerViewController.isAvailable)
        }
    }
}

struct CameraScanner: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            Text("Scanning View")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
                .interactiveDismissDisabled(true)
        }
    }
}
