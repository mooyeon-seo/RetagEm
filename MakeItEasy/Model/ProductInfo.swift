//
//  DownloadManager.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-13.
//

import Foundation
import OSLog
import Combine

struct ProductInfo: Codable, Hashable {
    let itemID: String
    let brand: String
    let sources: [String]
}
