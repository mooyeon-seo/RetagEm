//
//  MakeItEasyTests.swift
//  MakeItEasyTests
//
//  Created by Brian Seo on 2023-06-13.
//

import XCTest
@testable import MakeItEasy

final class MakeItEasyTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSanity() async throws {
        let parsedObjects = await DownloadManager().parseProductObjectFile(forResource: "products", withExtension: "json")
        XCTAssert(parsedObjects.count == 2523, "\(parsedObjects.count)")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
