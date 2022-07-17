//
//  CustomKeyboardTests.swift
//  CustomKeyboardTests
//
//  Created by J_Min on 2022/07/15.
//

import XCTest

class CustomKeyboardTests: XCTestCase {

    var keyboardManager: KeyboardIOManager!
    
    override func setUpWithError() throws {
        keyboardManager = KeyboardIOManager()
    }

    override func tearDownWithError() throws {
        keyboardManager = nil
    }
    
    
}
