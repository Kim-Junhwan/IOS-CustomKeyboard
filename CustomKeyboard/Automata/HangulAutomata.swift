//
//  HangulAutomata.swift
//  CustomKeyboard
//
//  Created by JunHwan Kim on 2022/07/14.
//

//오토마타의 상태를 정의
enum HangulStatus {
    case start //s0
    case chosung //s1
    case joongsung, dJoongsung //s2,s3
    case jongsung, dJongsung //s4, s5
    case endOne, endTwo //s6,s7
}

//입력된 키의 종류 판별 정의
enum HangulCHKind {
    case consonant //자음
    case vowel  //모음
}

//키 입력마다 쌓이는 입력 스택 정의
struct InpStack {
    var curhanst: HangulStatus //상태
    var key : UInt32 //방금 입력된 키 코드
    var charCode : String //조합된 코드
    var chKind : HangulCHKind // 입력된 키가 자음인지 모임인지
}

import Foundation

class HangulAutomata {
    
    var buffer: [String] = []
    
    var inpStack: [InpStack] = []
    
    var currentHangulState: HangulStatus?
    
    var chKind: HangulCHKind!
    
    var charCode: String!
    var oldKey: UInt32!
    var oldChKind: HangulCHKind?
    var keyCode: UInt32!
    
    var chosungTable: [String] = ["ㄱ","ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    var joongsungTable: [String] = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]
    
    var jongsungTable: [String] = [" ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ","ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
    
    var dJoongTable: [[String]] = [
        ["ㅗ","ㅏ","ㅘ"],
        ["ㅗ","ㅐ","ㅙ"],
        ["ㅗ","ㅣ","ㅚ"],
        ["ㅜ","ㅓ","ㅝ"],
        ["ㅜ","ㅔ","ㅞ"],
        ["ㅜ","ㅣ","ㅟ"],
        ["ㅡ","ㅣ","ㅢ"],
        ["ㅏ","ㅣ","ㅐ"],
        ["ㅓ","ㅣ","ㅔ"],
        ["ㅕ","ㅣ","ㅖ"],
        ["ㅑ","ㅣ","ㅒ"],
        ["ㅘ","ㅣ","ㅙ"]
    ]
    
    var dJongTable: [[String]] = [
        ["ㄱ","ㅅ","ㄳ"],
        ["ㄴ","ㅈ","ㄵ"],
        ["ㄴ","ㅎ","ㄶ"],
        ["ㄹ","ㄱ","ㄺ"],
        ["ㄹ","ㅁ","ㄻ"],
        ["ㄹ","ㅂ","ㄼ"],
        ["ㄹ","ㅅ","ㄽ"],
        ["ㄹ","ㅌ","ㄾ"],
        ["ㄹ","ㅍ","ㄿ"],
        ["ㄹ","ㅎ","ㅀ"],
        ["ㅂ","ㅅ","ㅄ"]
    ]
    
    func joongsungPair() -> Bool {
        for i in 0..<dJoongTable.count {
            if dJoongTable[i][0] == joongsungTable[Int(oldKey)] &&
                dJoongTable[i][1] == joongsungTable[Int(keyCode)] {
                keyCode = UInt32(joongsungTable.firstIndex(of: dJoongTable[i][2])!)
                return true
            }
        }
        return false
    }
    
    func jongsungPair() -> Bool {
        for i in 0..<dJongTable.count {
            if dJongTable[i][0] == jongsungTable[Int(oldKey)] &&
                dJongTable[i][1] == chosungTable[Int(keyCode)] {
                keyCode = UInt32(jongsungTable.firstIndex(of: dJongTable[i][2])!)
                return true
            }
        }
        return false
    }
    
    func isJoongSungPair(first: String, result: String) -> Bool {
        for i in 0..<dJoongTable.count {
            if dJoongTable[i][0] == first && dJoongTable[i][2] == result {
                return true
            }
        }
        return false
    }
    
    func decompositionChosung(charCode: UInt32) -> UInt32 {
        let unicodeHangul = charCode - 0xAC00
        let jongsung = (unicodeHangul) % 28
        let joongsung = ((unicodeHangul - jongsung) / 28) % 21
        let chosung = (((unicodeHangul - jongsung) / 28) - joongsung) / 21
        return chosung
    }
    
    func decompositionChosungJoongsung(charCode: UInt32) -> UInt32 {
        let unicodeHangul = charCode - 0xAC00
        let jongsung = (unicodeHangul) % 28
        let joongsung = ((unicodeHangul - jongsung) / 28) % 21
        let chosung = (((unicodeHangul - jongsung) / 28) - joongsung) / 21
        return combinationHangul(chosung: chosung, joongsung: joongsung, jongsung: keyCode)
    }
    
    func combinationHangul(chosung: UInt32 = 0, joongsung: UInt32, jongsung: UInt32 = 0) -> UInt32 {
        return (((chosung * 21) + joongsung) * 28) + jongsung + 0xAC00
    }
    
    func deleteBuffer() {
        if inpStack.count == 0 {
            if buffer.count > 0 {
                buffer.removeLast()
            }
        } else {
            if let popHanguel = inpStack.popLast() {
                if popHanguel.curhanst == .chosung {
                    buffer.removeLast()
                } else if popHanguel.curhanst == .joongsung ||
                            popHanguel.curhanst == .dJoongsung {
                    if inpStack[inpStack.count - 1].curhanst == .jongsung ||
                        inpStack[inpStack.count - 1].curhanst == .dJongsung {
                        buffer.removeLast()
                    }
                        buffer[buffer.count - 1] = inpStack[inpStack.count - 1].charCode
                } else {
                    if inpStack.isEmpty{
                        buffer.removeLast()
                    } else if popHanguel.chKind == .vowel {
                        if inpStack[inpStack.count - 1].curhanst == .jongsung {
                            if inpStack[inpStack.count - 1].chKind == .vowel {
                                if isJoongSungPair(first: joongsungTable[Int(inpStack[inpStack.count - 1].key)],
                                                   result: joongsungTable[Int(popHanguel.key)]) {
                                    buffer[buffer.count - 1] = inpStack[inpStack.count - 1].charCode
                                } else {
                                    buffer.removeLast()
                                }
                            }
                        } else {
                            buffer.removeLast()
                        }
                    } else {
                        buffer[buffer.count - 1] = inpStack[inpStack.count - 1].charCode
                    }
                }
                if inpStack.isEmpty {
                    currentHangulState = nil
                } else {
                    currentHangulState = inpStack[inpStack.count - 1].curhanst
                    oldKey = inpStack[inpStack.count - 1].key
                    oldChKind = inpStack[inpStack.count - 1].chKind
                    charCode = inpStack[inpStack.count - 1].charCode
                }
            }
        }
    }
}

extension HangulAutomata {
    func hangulAutomata(key: String) {
        var canBeJongsung: Bool = false
        if joongsungTable.contains(key) {
            chKind = .vowel
            keyCode = UInt32(joongsungTable.firstIndex(of: key)!)
        } else {
            chKind = .consonant
            keyCode = UInt32(chosungTable.firstIndex(of: key)!)
            if !((key == "ㄸ") || (key == "ㅉ") || (key == "ㅃ")) {
                canBeJongsung = true
            }
        }
        if currentHangulState != nil {
            oldKey = inpStack[inpStack.count - 1].key
            oldChKind = inpStack[inpStack.count - 1].chKind
        } else {
            currentHangulState = .start
            buffer.append("")
        }
        //MARK: - 오토마타 전이 알고리즘
        switch currentHangulState {
        case .start:
            if chKind == .consonant {
                currentHangulState = .chosung
            } else {
                currentHangulState = .jongsung
            }
        case .chosung:
            if chKind == .vowel {
                currentHangulState = .joongsung
            } else {
                currentHangulState = .endOne
            }
        case .joongsung:
            if canBeJongsung {
                currentHangulState = .jongsung
            } else if joongsungPair() {
                currentHangulState = .dJoongsung
            } else{
                currentHangulState = .endOne
            }
        case .dJoongsung:
            //추가
            if joongsungPair() {
                currentHangulState = .dJoongsung
            } else if canBeJongsung {
                currentHangulState = .jongsung
            } else {
                currentHangulState = .endOne
            }
        case .jongsung:
            if chKind == .consonant && jongsungPair() {
                currentHangulState = .dJongsung
            } else if chKind == .vowel {
                currentHangulState = .endTwo
            } else {
                currentHangulState = .endOne
            }
        case .dJongsung:
            if chKind == .vowel {
                currentHangulState = .endTwo
            } else {
                currentHangulState = .endOne
            }
        default:
            break
        }
        //MARK: - 오토마타 상태 별 작업 알고리즘
        switch currentHangulState {
        case .chosung:
            charCode = chosungTable[Int(keyCode)]
        case .joongsung:
            charCode = String(Unicode.Scalar(combinationHangul(chosung: oldKey, joongsung: keyCode))!)
        case .dJoongsung:
            let currentChosung = decompositionChosung(charCode: Unicode.Scalar(charCode)!.value)
            charCode = String(Unicode.Scalar(combinationHangul(chosung: currentChosung, joongsung: keyCode))!)
        case .jongsung:
            if canBeJongsung {
                keyCode = UInt32(jongsungTable.firstIndex(of: key)!)
                let currentCharCode =  Unicode.Scalar(charCode)!.value
                charCode = String(Unicode.Scalar(decompositionChosungJoongsung(charCode: currentCharCode))!)
            } else {
                charCode = key
            }
        case .dJongsung:
            let currentCharCode =  Unicode.Scalar(charCode)!.value
            charCode = String(Unicode.Scalar(decompositionChosungJoongsung(charCode: currentCharCode))!)
            keyCode = UInt32(jongsungTable.firstIndex(of: key)!)
        case .endOne:
            if chKind == .consonant {
                charCode = chosungTable[Int(keyCode)]
                currentHangulState = .chosung
            } else {
                charCode = joongsungTable[Int(keyCode)]
                currentHangulState = .jongsung
            }
            buffer.append("")
        case.endTwo:
            if oldChKind == .consonant {
                oldKey = UInt32(chosungTable.firstIndex(of: jongsungTable[Int(oldKey)])!)
                charCode =  String(Unicode.Scalar(combinationHangul(chosung: oldKey, joongsung: keyCode))!)
                currentHangulState = .joongsung
                buffer[buffer.count - 1] = inpStack[inpStack.count - 2].charCode
                buffer.append("")
            } else {
                if !joongsungPair() {
                    buffer.append("")
                }
                charCode = joongsungTable[Int(keyCode)]
                currentHangulState = nil
                currentHangulState = .jongsung
            }
        default:
            break
        }
        inpStack.append(InpStack(curhanst: currentHangulState!, key: keyCode, charCode: String(Unicode.Scalar(charCode)!), chKind: chKind))
        buffer[buffer.count - 1] = charCode
    }
}
