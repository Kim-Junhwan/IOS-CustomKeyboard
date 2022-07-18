//
//  CustomKeyboardView.swift
//  CustomKeyboard
//
//  Created by J_Min on 2022/07/12.
//

import UIKit

protocol CustomKeyboardDelegate : AnyObject{
    func hangulKeypadTap(char: String)
    func deleteKeypadTap()
    func enterKeypadTap()
    func spaceKeypadTap()
}

class CustomKeyboardView: UIView {
    
    static let identifier = "CustomKeyboardView"
    
    // MARK: - Properties
    var isShift : Bool = false
    weak var delegate : CustomKeyboardDelegate?
    
    // MARK: - Outlet
    @IBOutlet weak var firstLineStackView: UIStackView!
    @IBOutlet weak var shiftButton: UIButton!
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Action
    @IBAction func backKeypadTap(_ sender: UIButton) {
        delegate?.deleteKeypadTap()
    }
    
    @IBAction func enterKeypadTap(_ sender: UIButton) {
        delegate?.enterKeypadTap()
    }
    
    @IBAction func spaceKeypadTap(_ sender: UIButton) {
        delegate?.spaceKeypadTap()
    }
    
    @IBAction func shiftKeypadTap(_ sender: UIButton) {
        let stackButtons = firstLineStackView.subviews.filter {$0 is UIButton}
        let nonShiftKey = ["ㅂ","ㅈ","ㄷ","ㄱ","ㅅ","ㅛ","ㅕ","ㅑ","ㅐ","ㅔ"]
        let tapShiftKey = ["ㅃ","ㅉ","ㄸ","ㄲ","ㅆ","ㅛ","ㅕ","ㅑ","ㅒ","ㅖ"]
        var startKeyIndex = 0
        if isShift {
            isShift = false
            sender.backgroundColor = UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1.00)
            sender.setTitleColor(.white, for: .normal)
            for subButton in stackButtons {
                if let subButton = subButton as? UIButton {
                    subButton.setTitle(nonShiftKey[startKeyIndex], for: .normal)
                }
                startKeyIndex += 1
            }
        } else {
            isShift = true
            sender.backgroundColor = .systemGray2
            sender.setTitleColor(.black, for: .normal)
            for subButton in stackButtons {
                if let subButton = subButton as? UIButton{
                    subButton.setTitle(tapShiftKey[startKeyIndex], for: .normal)
                }
                startKeyIndex += 1
            }
        }
    }
    
    @IBAction func hangulKeypadTap(_ sender: UIButton) {
        delegate?.hangulKeypadTap(char: sender.currentTitle!)
        if isShift{
            shiftKeypadTap(shiftButton)
        }
    }
}
