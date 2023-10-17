//
//  DocumentViewModel.swift
//  Price Change List
//
//  Created by Brian Seo on 2023-06-01.
//

import UIKit
import Vision
import RegexBuilder
import CoreData
import OSLog

class Scanner: ObservableObject {
    private let logger = Logger(subsystem: "com.devil.red.MakeItEasy", category: "Scanner")
    @Published var scannedItemIDs: [String] = []
    
    var request: VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                let scannedText = topCandidate.string
                
                if let itemID = self.parseItemID(scannedText) {
                    self.logger.debug("scanned itemID \(itemID)")
                    self.scannedItemIDs.append(itemID.uppercased())
                }
            }
        }        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US", "en-GB"]
        request.usesLanguageCorrection = true
        return request
    }
    
    func scan(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.request])
        } catch {
            print(error)
        }
    }
}

extension Scanner {
    private func parseItemID(_ scannedText: String) -> String? {
        let components = scannedText.components(separatedBy: " ")
        if components.count == 2 {
            let firstComponent = String(components[0])
            if firstComponent.contains("/") && firstComponent.contains(where: { letter in
                "0123456789".contains(letter)
            }) {
                return String(components[1])
            }
        }
        return nil
    }
}
