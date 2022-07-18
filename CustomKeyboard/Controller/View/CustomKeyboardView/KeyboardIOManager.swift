//
//  KeyboardIOManager.swift
//  CustomKeyboard
//
//  Created by CHUBBY on 2022/07/13.
//

import Foundation

class KeyboardIOManager {
    var input: String = "" {
        didSet {
            updateTextView(input)
        }
    }
    
    var updateTextView: ((String) -> Void)!
    let automata = Automata()
    
}

extension KeyboardIOManager: CustomKeyboardDelegate {
    func hangulKeypadTap(char: String) {
        input = automata.makeSyllable(char)
    }
    
    func backKeypadTap() {
        
    }
    
    func enterKeypadTap() {
        
    }
    
    func spaceKeypadTap() {
        
    }
    
    
}
