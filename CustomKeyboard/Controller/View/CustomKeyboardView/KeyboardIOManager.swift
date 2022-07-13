//
//  KeyboardIOManager.swift
//  CustomKeyboard
//
//  Created by CHUBBY on 2022/07/13.
//

import Foundation

struct Hangul {
    let cho: [String] = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ",
        "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
        "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ",
        "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    
    let jung: [String] = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ",
        "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ",
        "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ",
        "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ",
        "ㅣ"
    ]
    
    let jong: [String] = [
        "", "ㄱ", "ㄲ", "ㄳ", "ㄴ",
        "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ",
        "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ",
        "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ",
        "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ",
        "ㅌ", "ㅍ", "ㅎ"
    ]
}

enum HalgulCharacterType {
    case cho, jun, jon
}

class KeyboardIOManager {
    var input: String = "" {
        didSet {
            updateTextView(input)
        }
    }
    
    var updateTextView: ((String) -> Void)!
    
    
}

extension KeyboardIOManager: CustomKeyboardDelegate {
    func hangulKeypadTap(char: String) {
        self.input = char
    }
    
    func backKeypadTap() {
        
    }
    
    func enterKeypadTap() {
        
    }
    
    func spaceKeypadTap() {
        
    }
}
