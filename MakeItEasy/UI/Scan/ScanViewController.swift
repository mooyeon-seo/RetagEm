//
//  CameraScannerViewController.swift
//  Price Change List
//
//  Created by Brian Seo on 2023-05-31.
//


import SwiftUI
import Vision
import VisionKit
import UIKit
import AVKit

struct ScanViewController: UIViewControllerRepresentable {
    @EnvironmentObject var document: Scanner
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(document) }
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        @Environment(\.presentationMode) var presentationMode
        @ObservedObject var document: Scanner
        
        init(_ document: Scanner) {
            self.document = document
        }
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else {
                controller.dismiss(animated: true)
                return
            }
            for index in 0..<scan.pageCount {
                self.document.scan(scan.imageOfPage(at: index))
            }
            
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
    }
}
