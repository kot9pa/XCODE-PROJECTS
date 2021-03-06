//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Konstantin on 07.03.17.
//  Copyright © 2017 Konstantin. All rights reserved.
//

import XCTest
@testable import Calculator

class CalculatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAssignment1() {
        
        var model = CalculatorModel()
        
        model.setOperand(7)
        model.performOperation("+")
        XCTAssertEqual(model.getDescription(), "7 + ...")
        XCTAssertEqual(model.result, 7.0)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
