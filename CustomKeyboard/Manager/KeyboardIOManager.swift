//
//  KeyboardIOManager.swift
//  CustomKeyboard
//
//  Created by CHUBBY on 2022/07/13.
//

import Foundation

class KeyboardIOManager {
    
    // MARK: - Properties
    var deleteKey = "jlk;jkl;jtoieruogjerqpioj893475982347jdgk+_+_+_+vd;ajdslfjls;djfoisduovucxoijoirhto4j9030923"
    var inputCaracter: ((String) -> Void)!
    var deleteCaracter: ((String, String, Bool) -> Void)!
    var dismiss: (() -> Void)!
    
    // extension
    private var hangul = Hangul()
    var inputQueue = [String]()
    private var queueText = ""
    private var sliceInputQueue = [[String]]()
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
    func sliceInputQueue(queue: [String]) -> [[String]] {
        var isFlag = false
        var buffer = [String]()
        var inputListMap = [[String]]()
        
        for (index, input) in queue.enumerated() {
            if isFlag { isFlag = false; continue }
            // buffer가 비었을경우
            if buffer.isEmpty {
                // input이 cho 일시 input을 buffer.append
                if hangul.cho.contains(input) {
                    buffer.append(input)
                } else {
                    // inputListMap이 비지 않았고 마지막의 마지막 원소가 cho인데
                    // input이 jung일때 inputListMap의 마지막의 마지막 원소를 빼서
                    // buffer 에 append 하고 input도 append
                    if !inputListMap.isEmpty,
                       hangul.cho.contains(inputListMap.last!.last!) {
                        let chosung = inputListMap[inputListMap.count - 1].removeLast()
                        buffer.append(chosung)
                        if index < queue.count - 1 &&
                            hangul.twiceJungValue.contains(input + queue[index + 1]) {
                            let target = input + queue[index + 1]
                            let targetIndex = hangul.twiceJungValue.firstIndex(of: target)!
                            buffer.append(hangul.jung[hangul.twiceJungIndexAndValue[targetIndex].1])
                            isFlag = true
                        } else {
                            buffer.append(input)
                        }
                        // inputListMap이 비지 않았고 마지막 원소가 ㄹㄱ <- 이런식일때
                        // 앞에꺼는 종성으로 냅두고 뒤에거는 버퍼의 스택으로 append 하고 input도 버퍼에 append
                    } else if !inputListMap.isEmpty,
                              hangul.jong.contains(inputListMap.last!.last!) {
                        inputListMap[inputListMap.count - 1].removeLast()
                        inputListMap[inputListMap.count - 1].append(queue[index - 2])
                        buffer.append(queue[index - 1])
                        buffer.append(input)
                    } else {
                        // queue의 마지막 인덱스가 아니고 중성이 twiceJung에 해당될때
                        // 조합해서 buffer에 append
                        if index < queue.count - 1 &&
                            hangul.twiceJungValue.contains(input + queue[index + 1]) {
                            let target = input + queue[index + 1]
                            let targetIndex = hangul.twiceJungValue.firstIndex(of: target)!
                            buffer.append(hangul.jung[hangul.twiceJungIndexAndValue[targetIndex].1])
                            isFlag = true
                        } else {
                            buffer.append(input)
                        }
                    }
                }
                continue
                // buffer가 한개 차있을경우 그리고 그 버퍼가 cho이면서 input이 jung일경우
            } else if buffer.count == 1 {
                if hangul.cho.contains(buffer[0]),
                   hangul.jung.contains(input) {
                    // queue의 마지막 인덱스가 아니고 중성이 twiceJung에 해당될때
                    // 조합해서 buffer에 append
                    if index < queue.count - 1 &&
                        hangul.twiceJungValue.contains(input + queue[index + 1]) {
                        let target = input + queue[index + 1]
                        let targetIndex = hangul.twiceJungValue.firstIndex(of: target)!
                        buffer.append(hangul.jung[hangul.twiceJungIndexAndValue[targetIndex].1])
                        isFlag = true
                    } else {
                        // buffer에 input append
                        buffer.append(input)
                    }
                    continue
                    // queue의 마지막 인덱스가 아니고 중성이 twiceJung에 해당될때
                    // 조합해서 buffer에 append
                } else if hangul.twiceJungValue.contains(buffer.last! + input) {
                    let target = buffer.removeLast() + input
                    let targetIndex = hangul.twiceJungValue.firstIndex(of: target)!
                    buffer.append(hangul.jung[hangul.twiceJungIndexAndValue[targetIndex].1])
                    isFlag = true
                    continue
                } else {
                    // buffer를 inputListMap에 append 한 후 초기화 후 input append
                    inputListMap.append(buffer)
                    buffer.removeAll()
                    buffer.append(input)
                    continue
                }
                // 버퍼가 두개 차있고 마지막 원소가 jung이면서 input이 jong일경우
            } else if buffer.count == 2 {
                if hangul.jung.contains(buffer[1]),
                   hangul.jong.contains(input) {
                    if index < queue.count - 1 &&
                        hangul.twiceJongValue.contains(input + queue[index + 1]) {
                        //                    buffer.removeLast()
                        let target = input + queue[index + 1]
                        let targetIndex = hangul.twiceJongValue.firstIndex(of: target)!
                        buffer.append(hangul.jong[hangul.twiceJongIndexAndValue[targetIndex].1])
                        isFlag = true
                    } else {
                        // buffer에 input append
                        buffer.append(input)
                    }
                    // buffer가 꽉 찼으므로 inputListMap에 append 하고 초기화
                    inputListMap.append(buffer)
                    buffer.removeAll()
                    continue
                    // 아닐경우
                } else {
                    // inputListMap에 buffer append하고 초기화 후 input append
                    inputListMap.append(buffer)
                    buffer.removeAll()
                    buffer.append(input)
                }
            }
        }
        // 혹시 buffer에 데이터가 남아있을경우 inputListMap에 append
        if !buffer.isEmpty { inputListMap.append(buffer) }
        return inputListMap
    }
    
    /// 초성, 중성, 종성으로 나뉘어진 문자들 단어 하나로 합치기
    func joinHangul(inputListMap: [[String]]) -> String {
        var result = ""
        
        // 조합
        inputListMap.forEach { buffer in
            // buffer가 3개 다있을경우 초성, 중성, 종성 계산해서 조합
            if buffer.count == 3 {
                let chosung = hangul.cho.firstIndex(of: buffer[0])!
                let jungsung = hangul.jung.firstIndex(of: buffer[1])!
                let jongsung = hangul.jong.firstIndex(of: buffer[2])!
                let joinChar = (chosung * 21 + jungsung) * 28 + jongsung + 0xAC00
                if let uni = Unicode.Scalar(joinChar) {
                    result += String(uni)
                }
                // buffer가 두개있을경우 초성, 중성만 계산해서 조합
            } else if buffer.count == 2 {
                let chosung = hangul.cho.firstIndex(of: buffer[0])!
                let jungsung = hangul.jung.firstIndex(of: buffer[1])!
                let joinChar = (chosung * 21 + jungsung) * 28 + 0xAC00
                if let uni = Unicode.Scalar(joinChar) {
                    result += String(uni)
                }
                // buffer가 한개일경우 그냥 사용
            } else if buffer.count == 1 {
                result += buffer.first!
            }
        }
        return result
    }
    
    /// queue에 저장된 문자들 나누고 합치기
    func join(queue: [String]) -> String {
        let sliceInputQueue = sliceInputQueue(queue: queue)
        return joinHangul(inputListMap: sliceInputQueue)
    }
}
