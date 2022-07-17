//
//  Hangul.swift
//  CustomKeyboard
//
//  Created by J_Min on 2022/07/14.
//

import Foundation

struct Hangul {
    let cho: [String] = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ",
        "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ",
        "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    
    let jung: [String] = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ",
        "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ",
        "ㅝ","ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"
    ]
    
    let jong: [String] = [
        " ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ",
        "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ",
        "ㄿ","ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ",
        "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    
    let doubleJungValueAndSumValue: [(String, String)] = [
        ("ㅗㅏ", "ㅘ"), ("ㅗㅐ", "ㅙ"), ("ㅗㅣ", "ㅚ"), ("ㅜㅓ", "ㅝ"),
        ("ㅜㅔ", "ㅞ"), ("ㅜㅣ", "ㅟ"), ("ㅡㅣ", "ㅢ"), ("ㅏㅣ", "ㅐ"),
        ("ㅓㅣ", "ㅔ"), ("ㅑㅣ", "ㅒ"), ("ㅕㅣ", "ㅖ")
    ]
    
    let doubleJongValueAndSumValue: [(String, String)] = [
        ("ㄱㅅ", "ㄳ"), ("ㄴㅈ", "ㄵ"), ("ㄴㅎ", "ㄶ"), ("ㄹㄱ", "ㄺ"),
        ("ㄹㅁ", "ㄻ"), ("ㄹㅂ", "ㄼ"), ("ㄹㅅ", "ㄽ"), ("ㄹㅌ", "ㄾ"),
        ("ㄹㅍ", "ㄿ"), ("ㄹㅎ", "ㅀ"), ("ㅂㅅ", "ㅄ")
    ]
    
    lazy var doubleJungValue = doubleJungValueAndSumValue.map { $0.0 }
    lazy var doubleJongValue = doubleJongValueAndSumValue.map { $0.0 }
}
