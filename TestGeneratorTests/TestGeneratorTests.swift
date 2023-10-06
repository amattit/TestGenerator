//
//  TestGeneratorTests.swift
//  TestGeneratorTests
//
//  Created by Серегин Михаил Андреевич on 06.10.2023.
//

import XCTest
@testable import TestGenerator

final class TestGeneratorTests: XCTestCase {

    var viewModel: TestGenerationViewModel!
    override func setUpWithError() throws {
        viewModel = .init()
        
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }

    func testExample() throws {
        let generated = viewModel.generate()
        print(generated)
        XCTAssertEqual(generated.count, 2)
    }
    
    func testNormalizeClassName() {
        let name = viewModel.normalizeClassName(classname: "public final class RecommendationViewModel: ObservableObject, RecommendationViewModelDelegate")
        print(name)
        XCTAssertEqual(name, "RecommendationViewModel")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            _ = viewModel.generate()
        }
    }

}
