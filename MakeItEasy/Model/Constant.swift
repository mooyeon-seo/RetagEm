//
//  Constant.swift
//  MakeItEasy
//
//  Created by Brian Seo on 2023-06-25.
//

import SwiftUI

struct Constant {
    struct UI {
        static func ScanButton(_ color: Color) -> some View {
            ZStack {
                Circle()
                    .strokeBorder(color, lineWidth: 3)
                    .frame(width: 62, height: 62)
                Circle()
                    .fill(color)
                    .frame(width: 50, height: 50)
            }
        }
    }
    static let totalNumberOfProducts = 4020
    static let totalNumberOfImages = 22542
}
