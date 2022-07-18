//
//  Automata.swift
//  CustomKeyboard
//
//  Created by CHUBBY on 2022/07/18.
//

import Foundation
import UIKit

class Automata {
    
    enum InputStatus {
        case start
        case choseong
        case jungseong
        case doubleJungseong
        case jongseong
        case doubleJongseong
        case finish
    }
    
    enum InputKind {
        case consonant
        case vowel
        case space
        case back
    }
 
    var choIndex: Int = 0
    var jungIndex: Int = 0
    var jongIndex: Int = 0

    var syllableStorage: [[String]] = [[]]
    var syllable: [String] = []
    var currentString = ""

    var inputStatus = InputStatus.start
    var inputKind: InputKind?
    
    func makeSyllable(_ input: String) -> String {
        
        if choArray.contains(input) || jongArray.contains(input) {
            inputKind = .consonant
        } else if jungArray.contains(input) {
            inputKind = .vowel
        } else if input == "BACK" {
            inputKind = .back
        } else if input == "SPACE" {
            inputKind = .space
        }
        
        switch inputStatus {
        case .start:
            start(input)
        case .choseong:
            if inputKind == .consonant {
                choseong(input)
            } else {
                jungseong(input)
            }
        case .jungseong:
            if inputKind == .vowel {
                jungseong(input)
            } else {
                start(input)
            }
        case .doubleJungseong:
            if inputKind == .vowel {
                doubleJungseong(input)
            } else {
                jongseong(input)
            }
        case .jongseong:
            if inputKind == .vowel {
                jungseong(input)
            } else {
                jongseong(input)
            }
        case .doubleJongseong:
            if inputKind == .vowel {
                seperateSyllable(by: input)
            } else {
                doubleJongseong(input)
            }
        case .finish:
            if inputKind == .vowel {
                seperateSyllable(by: input)
            } else {
                inputStatus = .start
                start(input)
            }
        }
        
        print(assembleSyllable())
        print(syllable)
        print(syllableStorage)
        return assembleSyllable()
    }
    
    func start(_ input: String) {
        print(#function)
        if choArray.contains(input) {
            if doubleChoArray.contains(where: {$0.0 == input }) {
                inputStatus = .choseong
            } else {
                inputStatus = .jungseong
            }
        } else {
            if doubleJungArray.contains(where: {$0.0 == input}) {
                inputStatus = .doubleJungseong
            } else {
                inputStatus = .start
            }
        }
        syllable = [input]
        syllableStorage.append(syllable)
    }
    
    func choseong(_ currentInput: String) {
        print(#function)
        let prevInput = syllable[0]
        if prevInput == currentInput {
            syllable = [didDoubleOnset(with: currentInput)]
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .jungseong
        } else {
            syllable = [currentInput]
            syllableStorage.append(syllable)
            inputStatus = .choseong
        }
    }

    func didDoubleOnset(with currentInput: String) -> String {
        print(#function)
        guard let index = doubleChoArray.firstIndex(where: {$0.0 == currentInput}) else { return "" }
        return doubleChoArray[index].2
    }

    func jungseong(_ currentInput: String) {
        print(#function)
        if doubleJungArray.contains(where: {$0.0 == currentInput}) { // 복합모음 가능성 O
            syllable.append(currentInput)
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .doubleJungseong
        } else { // 복합모음 가능성 X
            syllable.append(currentInput)
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .jongseong
        }
    }

    func doubleJungseong(_ currentInput: String) {
        print(#function)
        let prevInput = syllable[syllable.count - 1]
        if canBeDoubleJungseong(with: prevInput, currentInput) {
            syllable[1] = didDoubleNucleus(with: prevInput, currentInput)
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .jongseong
        } else {
            syllable = [didDoubleNucleus(with: prevInput, currentInput)]
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .start
        }
    }
    
    func canBeDoubleJungseong(with prevInput: String, _ currentInput: String) -> Bool {
        print(#function)
        var bool: Bool = false
        doubleJungArray.forEach {
            if $0.0 == prevInput, $0.1 == currentInput {
                bool = true
            }
        }
        return bool
    }

    func didDoubleNucleus(with previousInput: String, _ currentInput: String) -> String {
        print(#function)
        var result = ""
        doubleJungArray.forEach {
            if $0.0 == previousInput && $0.1 == currentInput {
                result = $0.2
            }
        }
        return result
    }

    func jongseong(_ currentInput: String) {
        print(#function)
        if doubleJongArray.contains(where: {$0.0 == currentInput}) {
            syllable.append(currentInput)
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .doubleJongseong
        } else {
            syllable.append(currentInput)
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .finish
        }
    }

    func doubleJongseong(_ currentInput: String) {
        print(#function)
        let prevInput = syllable[syllable.count - 1]
        if canBeDoubleJongseong(with: prevInput, currentInput) {
            let doubleJongseong = didDoubleJongseong(with: prevInput, currentInput)
            syllable[2] = doubleJongseong
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .finish
        } else {
            syllable = [currentInput]
            syllableStorage.append(syllable)
            inputStatus = .jungseong
        }
    }
    
    func canBeDoubleJongseong(with prevInput: String, _ currentInput: String) -> Bool {
        print(#function)
        var bool: Bool = false
        doubleJongArray.forEach {
            if $0.0 == prevInput, $0.1 == currentInput {
                bool = true
            }
        }
        return bool
    }

    func didDoubleJongseong(with previousInput: String, _ currentInput: String) -> String {
        print(#function)
        var result = ""
        doubleJongArray.forEach {
            if $0.0 == previousInput, $0.1 == currentInput {
                result = $0.2
            }
        }
        return result
    }
    
    func seperateSyllable(by input: String) {
        print(#function)
        guard let latestJong = syllableStorage.last?.last else { return }
        if doubleJongArray.contains(where: {$0.2 == latestJong}) { // 마지막 받침이 쌍자음
            guard let index = doubleJongArray.firstIndex(where: { $0.2 == latestJong }) else { return }
            syllableStorage[syllableStorage.count - 1][2] = doubleJongArray[index].0
            syllable = [doubleJongArray[index].1, input]
        } else if jongArray.contains(latestJong) { // 마지막 받침이 홑자음
            syllableStorage[syllableStorage.count - 1].removeLast()
            syllable = [latestJong, input]
        }
        syllableStorage.append(syllable)
        inputStatus = .doubleJungseong
    }
    
    func getCompositedString(cho: Int, jung: Int, jong: Int) -> String {
        let compositedString = UnicodeScalar(0xAC00 + (choIndex * 588) + (jungIndex * 28) + jongIndex)!
        return String(compositedString)
    }

    // 초/중/종 조합하여 한 글자로 합치기
    func assembleSyllable() -> String {
        print(#function)
        var result = ""
        
        syllableStorage.forEach { syllable in
            if syllable.count == 3 {
                choIndex = choArray.firstIndex(of: syllable[0]) ?? 0
                jungIndex = jungArray.firstIndex(of: syllable[1]) ?? 0
                jongIndex = jongArray.firstIndex(of: syllable[2]) ?? 0
                result += getCompositedString(cho: choIndex, jung: jungIndex, jong: jongIndex)
            } else if syllable.count == 2 {
                choIndex = choArray.firstIndex(of: syllable[0]) ?? 0
                jungIndex = jungArray.firstIndex(of: syllable[1]) ?? 0
                jongIndex = 0
                result += getCompositedString(cho: choIndex, jung: jungIndex, jong: jongIndex)
            } else if syllable.count == 1 {
                result += syllable[0]
            }
            
        }
        return result
    }
    
    // 한 글자를 초/중/종으로 분리하기
    func deassembleSyllable(_ char: String) {
        let unicodeValue = Int(UnicodeScalar(char)!.value)
        print(unicodeValue)

        let choIndex = (unicodeValue - 0xAC00) / 28 / 21
        let jungIndex = ((unicodeValue - 0xAC00) / 28) % 21
        let jongIndex = (unicodeValue - 0xAC00) % 28

        let cho = UnicodeScalar(0x1100 + choIndex)! // 0x1100 : 초성유니코드 시작값
        let jung = UnicodeScalar(0x1161 + jungIndex)! // 0x1161 : 중성유니코드 시작값
        let jong = UnicodeScalar(0x11a7 + jongIndex)! // 0x11a6 : 종성유니코드 시작값
        
        print(unicodeValue) // 한글에서 unicode 값으로 변환 : 55179
        print(choIndex, jungIndex, jongIndex)
        print(UnicodeScalar(unicodeValue)!) // Unicode 값에서 한글로 변환 : "힋"
        print(cho) // ㅎ
        print(jung) // ㅣ
        print(jong) // ㄳ
    }
    
    func backKeypadTap() {
        if !syllableStorage.isEmpty {
            syllableStorage[syllableStorage.count - 1].removeLast()
        }
        print(syllable)
        print(syllableStorage)
    }

    func spaceKeypadTap() {
        syllable.append(" ")
        print(syllable)
        print(syllableStorage)
    }
}
