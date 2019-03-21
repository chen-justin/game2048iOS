//
//  game2048Tests.swift
//  game2048Tests
//
//  Created by Justin Chen on 3/20/19.
//  Copyright © 2019 Justin Chen. All rights reserved.
//

import XCTest
@testable import game2048

class game2048Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let game = Game(withSize: 5)
        game.left()
        print(game.getState())
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
