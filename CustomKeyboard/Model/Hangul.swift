//
//  Hangul.swift
//  CustomKeyboard
//
//  Created by J_Min on 2022/07/14.
//

import Foundation

struct Hangul {
    let cho:[String] = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
    
    let jung:[String] = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ","ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]
    let jong:[String] = [" ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ","ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    let twiceJungIndexAndValue: [(String, Int)] = [("ㅗㅏ", 9), ("ㅗㅐ", 10), ("ㅗㅣ", 11), ("ㅜㅓ", 14), ("ㅜㅔ", 15), ("ㅜㅣ", 16), ("ㅡㅣ", 19), ("ㅏㅣ", 1), ("ㅓㅣ", 5), ("ㅑㅣ", 3), ("ㅕㅣ", 7)]
    
    let twiceJongIndexAndValue: [(String, Int)] = [("ㄱㅅ", 3), ("ㄴㅈ", 5), ("ㄴㅎ", 6), ("ㄹㄱ", 9), ("ㄹㅁ", 10), ("ㄹㅂ", 11), ("ㄹㅅ", 12), ("ㄹㅌ", 13), ("ㄹㅍ", 14), ("ㄹㅎ", 15), ("ㅂㅅ", 18), ("ㅅㅅ", 20), ("ㄱㄱ", 2)]
    
    lazy var twiceJungValue = twiceJungIndexAndValue.map { $0.0 }
    lazy var twiceJongValue = twiceJongIndexAndValue.map { $0.0 }
}
