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
    
// MARK: - automata handling
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
    
// MARK: - start
    func start(_ currInput: String) {
        print(#function)
        if choArray.contains(currInput) {
            if doubleChoArray.contains(where: {$0.0 == currInput }) {
                inputStatus = .choseong
            } else {
                inputStatus = .jungseong
            }
        } else {
            if doubleJungArray.contains(where: {$0.0 == currInput}) {
                inputStatus = .doubleJungseong
            } else {
                inputStatus = .start
            }
        }
        syllable = [currInput]
        syllableStorage.append(syllable)
    }
    
// MARK: - choseong handling
    func choseong(_ currInput: String) {
        print(#function)
        let prevInput = syllable[0]
        if prevInput == currInput {
            syllable = [didDoubleChoseong(with: currInput)]
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .jungseong
        } else {
            syllable = [currInput]
            syllableStorage.append(syllable)
            inputStatus = .choseong
        }
    }

    func didDoubleChoseong(with currInput: String) -> String {
        print(#function)
        guard let index = doubleChoArray.firstIndex(where: {$0.0 == currInput}) else { return "" }
        return doubleChoArray[index].2
    }
    
// MARK: - jungseong handling
    func jungseong(_ currInput: String) {
        print(#function)
        if doubleJungArray.contains(where: {$0.0 == currInput}) {
            syllable.append(currInput)
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .doubleJungseong
        } else {
            syllable.append(currInput)
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .jongseong
        }
    }
    
    func canBeDoubleJungseong(with prevInput: String, _ currInput: String) -> Bool {
        print(#function)
        var bool: Bool = false
        doubleJungArray.forEach {
            if $0.0 == prevInput, $0.1 == currInput { bool = true }
        }
        return bool
    }
    
    func doubleJungseong(_ currInput: String) {
        print(#function)
        let prevInput = syllable[syllable.count - 1]
        if canBeDoubleJungseong(with: prevInput, currInput) {
            syllable[1] = didDoubleJungseong(with: prevInput, currInput)
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .jongseong
        } else {
            syllable = [didDoubleJungseong(with: prevInput, currInput)]
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .start
        }
    }

    func didDoubleJungseong(with prevInput: String, _ currInput: String) -> String {
        print(#function)
        var result = ""
        doubleJungArray.forEach {
            if $0.0 == prevInput && $0.1 == currInput { result = $0.2 }
        }
        return result
    }

// MARK: - jongseong handling
    func jongseong(_ currInput: String) {
        print(#function)
        if doubleJongArray.contains(where: {$0.0 == currInput}) {
            syllable.append(currInput)
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .doubleJongseong
        } else {
            if currInput == "ㄸ" || currInput == "ㅃ" || currInput == "ㅉ" {
                syllable = [currInput]
                syllableStorage.append(syllable)
                inputStatus = .jungseong
            } else {
                syllable.append(currInput)
                syllableStorage[syllableStorage.count - 1] = syllable
                inputStatus = .finish
            }
        }
    }
    
    func canBeDoubleJongseong(with prevInput: String, _ currInput: String) -> Bool {
        print(#function)
        var bool: Bool = false
        doubleJongArray.forEach {
            if $0.0 == prevInput, $0.1 == currInput { bool = true }
        }
        return bool
    }

    func doubleJongseong(_ currInput: String) {
        print(#function)
        let prevInput = syllable[syllable.count - 1]
        if canBeDoubleJongseong(with: prevInput, currInput) {
            let doubleJongseong = didDoubleJongseong(with: prevInput, currInput)
            syllable[2] = doubleJongseong
            syllableStorage[syllableStorage.count - 1] = syllable
            inputStatus = .finish
        } else {
            syllable = [currInput]
            syllableStorage.append(syllable)
            inputStatus = .jungseong
        }
    }

    func didDoubleJongseong(with prevInput: String, _ currInput: String) -> String {
        print(#function)
        var result = ""
        doubleJongArray.forEach {
            if $0.0 == prevInput, $0.1 == currInput { result = $0.2 }
        }
        return result
    }
    
// MARK: - assemble & deassemble
    
    // 모음이 입력되어 앞 글자의 받침과 분리되면서 한 글자 완성하기
    func seperateSyllable(by input: String) {
        print(#function)
        guard let latestJong = syllableStorage.last?.last else { return }
        if doubleJongArray.contains(where: {$0.2 == latestJong}) {
            guard let index = doubleJongArray.firstIndex(where: { $0.2 == latestJong }) else { return }
            syllableStorage[syllableStorage.count - 1][2] = doubleJongArray[index].0
            syllable = [doubleJongArray[index].1, input]
        } else if jongArray.contains(latestJong) {
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

}
