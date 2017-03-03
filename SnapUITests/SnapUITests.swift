//
//  SnapUITests.swift
//  SnapUITests
//
//  Created by Muhd Mirza on 14/1/17.
//  Copyright © 2017 muhdmirzamz. All rights reserved.
//

import XCTest

class SnapUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTakingPhoto() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		XCUIDevice.shared().orientation = .portrait
		XCUIDevice.shared().orientation = .faceUp
		
		let app = XCUIApplication()
		app.buttons["take pic"].tap()
		app.buttons["PhotoCapture"].tap()
		app.buttons["Use Photo"].tap()
		
		// use accessibility label
		XCTAssertNotNil(app.images["imageView"])
    }
}
