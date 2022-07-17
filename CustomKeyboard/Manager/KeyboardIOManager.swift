//
//  KeyboardIOManager.swift
//  CustomKeyboard
//
//  Created by CHUBBY on 2022/07/13.
//

import Foundation

class KeyboardIOManager {
    
    enum HangulState {
        case start, cho, jung, jong
    }
    
    enum InputQueueState {
        case empty, exist
    }
    
    // MARK: - Properties
    var deleteKey = "jlk;jkl;jtoieruogjerqpioj893475982347jdgk+_+_+_+vd;ajdslfjls;djfoisduovucxoijoirhto4j9030923"
    var inputCaracter: ((String) -> Void)!
    var deleteCaracter: ((String, String, Bool) -> Void)!
    var dismiss: (() -> Void)!
    
    // extension
    private var hangul = Hangul()
    var inputQueue = [String]()
    private var queueText = ""
    // extension
}

// MARK: - CustomKeyboardDelegate
extension KeyboardIOManager: CustomKeyboardDelegate {
    func hangulKeypadTap(char: String) {
        inputQueue.append(char)
        let joinHangul = join(queue: inputQueue)
        queueText = joinHangul
        inputCaracter(joinHangul)
    }
    
    func backKeypadTap() {
        if inputQueue.count >= 2 {
            inputQueue.removeLast()
            let joinQueue = join(queue: inputQueue)
            guard let lastCaracter = joinQueue.last else {
                deleteCaracter("", "", false)
                return
            }
            if joinQueue.count == queueText.count {
                deleteCaracter(String(lastCaracter), joinQueue, true)
            } else {
                deleteCaracter(String(lastCaracter), joinQueue, false)
            }
            queueText = joinQueue
        } else {
            inputQueue.removeAll()
            deleteCaracter(deleteKey, "", false)
        }
    }
    
    func enterKeypadTap() {
        dismiss()
    }
    
    func spaceKeypadTap() {
        inputQueue = [" "]
        inputCaracter(" ")
    }
}

// MARK: - automata
extension KeyboardIOManager {
    /// queue에 저장된 문자들 초성, 중성, 종성으로 나누기
    private func sliceInputQueue(queue: [String]) -> [[String]] {
        var inputListMap = [[String]]()
        var state = HangulState.start
        let lastIndex = queue.count - 1
        var buffer = [String]()
        var flag = false
        
        for (index, input) in queue.enumerated() {
            if flag { flag = false; continue }
            
            switch state {
            case .start:
                stateStart(queue, index: index, lastIndex: lastIndex, flag: &flag, input: input,
                           buffer: &buffer, inputListMap: &inputListMap, state: &state)
            case .cho:
                stateCho(queue, index: index, lastIndex: lastIndex, flag: &flag, input: input,
                         buffer: &buffer, inputListMap: &inputListMap, state: &state)
            case .jung:
                stateJung(queue, index: index, lastIndex: lastIndex, flag: &flag, input: input,
                          buffer: &buffer, inputListMap: &inputListMap, state: &state)
            case .jong:
                stateJong(queue, index: index, lastIndex: lastIndex, flag: &flag, input: input,
                          buffer: &buffer, inputListMap: &inputListMap, state: &state)
            }
        }
        
        if !buffer.isEmpty { inputListMap.append(buffer) }
        
        return inputListMap
    }
    
    /// inputListMap을 하나의 문장으로 조합
    private func joinHangul(inputListMap: [[String]]) -> String {
        var result = ""
        
        inputListMap.forEach { buffer in
            switch buffer.count {
            case 1:
                result += buffer.first!
            case 2:
                result += joinBuffer(buffer: buffer)
            case 3:
                result += joinBuffer(buffer: buffer)
            default:
                break
            }
        }
        return result
    }
    
    /// queue에 저장된 문자들 나누고 합치기
    private func join(queue: [String]) -> String {
        let sliceInputQueue = sliceInputQueue(queue: queue)
        return joinHangul(inputListMap: sliceInputQueue)
    }
}

// MARK: - Helper
extension KeyboardIOManager {
    /// state가 start일때
    private func stateStart(_ queue: [String], index: Int, lastIndex: Int, flag: inout Bool, input: String,
                    buffer: inout [String], inputListMap: inout [[String]], state: inout HangulState) {
        if hangul.cho.contains(input) {
            // 자음일때
            buffer.append(input)
            state = .cho
        } else {
            // 모음일때
            if index < lastIndex {
                let checkResult = checkAndSumDoubleJungsung(input, queue[index + 1])
                inputListMap.append([checkResult.value])
                if checkResult.valid { flag = true }
            } else {
                inputListMap.append([input])
            }
            state = .start
        }
    }

    /// state가 cho일때
    private func stateCho(_ queue: [String], index: Int, lastIndex: Int, flag: inout Bool, input: String,
                  buffer: inout [String], inputListMap: inout [[String]], state: inout HangulState) {
        if hangul.cho.contains(input) {
            // 자음일때
            inputListMap.append(buffer)
            buffer = [input]
            state = .cho
        } else {
            // 모음일때
            if index < lastIndex {
                let checkResult = checkAndSumDoubleJungsung(input, queue[index + 1])
                buffer.append(checkResult.value)
                if checkResult.valid { flag = true }
            } else {
                buffer.append(input)
            }
            state = .jung
        }
    }

    /// state가 jung일때
    private func stateJung(_ queue: [String], index: Int, lastIndex: Int, flag: inout Bool, input: String,
                   buffer: inout [String], inputListMap: inout [[String]], state: inout HangulState) {
        if hangul.jong.contains(input) {
            // 자음일때
            if index < lastIndex {
                let checkResult = checkAndSumDoubleJongsung(input, queue[index + 1])
                buffer.append(checkResult.value)
                if checkResult.valid { flag = true }
            } else {
                buffer.append(input)
            }
            state = .jong
        } else {
            // 모음일때
            inputListMap.append(buffer)
            buffer = [input]
            state = hangul.cho.contains(input) ? .cho : .jung
        }
    }

    /// state가 jong일때
    private func stateJong(_ queue: [String], index: Int, lastIndex: Int, flag: inout Bool, input: String,
                   buffer: inout [String], inputListMap: inout [[String]], state: inout HangulState) {
        if hangul.cho.contains(input) {
            // 자음일때
            inputListMap.append(buffer)
            buffer = [input]
            state = .cho
        } else {
            // 모음일때
            let jungsung: [String]
            if index < lastIndex {
                let checkResult = checkAndSumDoubleJungsung(input, queue[index + 1])
                jungsung = [checkResult.value]
                if checkResult.valid { flag = true }
            } else {
                jungsung = [input]
            }
            
            let sliceResult = sliceDoubleJongsung(char: buffer.removeLast())
            if sliceResult.count == 2 {
                // 쌍자음일때
                buffer.append(sliceResult[0])
                inputListMap.append(buffer)
                buffer = [String(sliceResult[1])] + jungsung
            } else {
                // 아닐때
                inputListMap.append(buffer)
                buffer = [String(sliceResult[0])] + jungsung
            }
            state = .jung
        }
    }
    
    /// 중성이 쌍모음인지 확인
    private func isDoubleJungsung(_ first: String, _ second: String) -> Bool {
        let target = first + second
        if hangul.doubleJungValue.contains(target) {
            return true
        } else {
            return false
        }
    }

    /// 모음 두개를 쌍모음 한개로 합치기
    private func addDoubleJungsung(_ first: String, _ second: String) -> String {
        let target = first + second
        let targetIndex = hangul.doubleJungValue.firstIndex(of: target)!
        return hangul.doubleJungValueAndSumValue[targetIndex].1
    }

    /// 중성이 쌍모음인지 확인하고 쌍모음이라면 한개로 합쳐서 리턴
    /// 쌍모음이 아니면 원래 모음만 리턴
    private func checkAndSumDoubleJungsung(_ first: String, _ second: String) -> (value: String, valid: Bool) {
        if isDoubleJungsung(first, second) {
            return (addDoubleJungsung(first, second), true)
        } else {
            return (first, false)
        }
    }

    /// 종성이 쌍모음인지 확인
    private func isDoubleJongsung(_ first: String, _ second: String) -> Bool {
        let target = first + second
        if hangul.doubleJongValue.contains(target) {
            return true
        } else {
            return false
        }
    }

    /// 모음 두개를 쌍모음 한개로 합치기
    private func addDoubleJongsung(_ first: String, _ second: String) -> String {
        let target = first + second
        let targetIndex = hangul.doubleJongValue.firstIndex(of: target)!
        return hangul.doubleJongValueAndSumValue[targetIndex].1
    }

    /// 종성이 쌍자음인지 확인후  쌍자음이라면 한개로 합쳐서 리턴
    /// 쌍자음이 아니면 원래 자음만 리턴
    private func checkAndSumDoubleJongsung(_ first: String, _ second: String) -> (value: String, valid: Bool) {
        if isDoubleJongsung(first, second) {
            return (addDoubleJongsung(first, second), true)
        } else {
            return (first, false)
        }
    }

    /// 쌍자음을 자음 두개로 나누기
    private func sliceDoubleJongsung(char: String) -> [String] {
        let doubleJongsung = hangul.doubleJongValueAndSumValue.map { $0.1 }
        if doubleJongsung.contains(char) {
            let index = doubleJongsung.firstIndex(of: char)!
            let doubleJong = hangul.doubleJongValueAndSumValue[index].0
            return [String(doubleJong.first!), String(doubleJong.last!)]
        } else {
            return [char]
        }
    }
    
    /// buffer에 있는것을 하나의 단어로 조합
    private func joinBuffer(buffer: [String]) -> String {
        var chosung: Int = 0
        var jungsung: Int = 0
        var jongsung: Int = 0
        
        buffer.enumerated().forEach { index, char in
            switch index {
            case 0:
                chosung = hangul.cho.firstIndex(of: buffer[0])!
            case 1:
                jungsung = hangul.jung.firstIndex(of: buffer[1])!
            case 2:
                jongsung = hangul.jong.firstIndex(of: buffer[2])!
            default:
                break
            }
        }
        
        let joinUniValue = (chosung * 21 + jungsung) * 28 + jongsung + 0xAC00
        
        if let uni = Unicode.Scalar(joinUniValue) {
            return String(uni)
        }
        return ""
    }
}
