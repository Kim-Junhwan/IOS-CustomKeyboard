//
//  WriteReviewViewController.swift
//  CustomKeyboard
//
//  Created by J_Min on 2022/07/12.
//

import UIKit

protocol WriteReviewViewControllerDelegate: AnyObject {
    func sendReviewMessage(review: String)
}

class WriteReviewViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: WriteReviewViewControllerDelegate?
    let keyboardIOManager = KeyboardIOManager()
    private var beforeCusorAfterString = ""
    private var currentCombinationText = " "
    
    // MARK: - ViewProperties
    private lazy var customKeyboard: CustomKeyboardView = {
        guard let customKeyboard = Bundle.main.loadNibNamed(CustomKeyboardView.identifier, owner: nil)?.first as? CustomKeyboardView else {
            return CustomKeyboardView()
        }
        customKeyboard.delegate = keyboardIOManager
        
        return customKeyboard
    }()
    
    private lazy var writeReviewTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.inputView = customKeyboard
        textView.becomeFirstResponder()
        
        return textView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindingKeyboardIOManager()
        writeReviewTextView.delegate = self
        view.backgroundColor = .systemBackground
        configureSubViews()
        setConstraintsOfWriteReviewTextView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.sendReviewMessage(review: writeReviewTextView.text)
    }
    
    // MARK: - Method
    func bindingKeyboardIOManager() {
        keyboardIOManager.inputCaracter = { [weak self] in
            guard let self = self else { return }
            if !$1 {
                print("hgjgygjh")
                self.writeReviewTextView.deleteBackward()
                self.currentCombinationText.removeLast()
                self.currentCombinationText.append($0)
            } else {
                self.currentCombinationText = " "
            }
            self.writeReviewTextView.insertText($0)
        }
        
        keyboardIOManager.deleteCaracter = { [weak self] in
            guard let self = self else { return }
            if !$0.isEmpty {
                let count = self.currentCombinationText.count == $0.count ?
                $0.count : $0.count + 1
                (0..<count).forEach { _ in
                    self.writeReviewTextView.deleteBackward()
                }
                self.writeReviewTextView.insertText($0)
            } else {
                self.writeReviewTextView.deleteBackward()
            }
            self.currentCombinationText = $0
            if self.currentCombinationText == "" {
                self.currentCombinationText = " "
            }
        }
        
        keyboardIOManager.dismiss = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    /// 텍스트뷰의 커서 앞의 문자 가져오기
    private func getStringAfterCursor() -> String {
        guard let selectedRange = writeReviewTextView.selectedTextRange,
              let text = writeReviewTextView.text else { return "" }
        
        let cursorPosition = writeReviewTextView.offset(from: writeReviewTextView.beginningOfDocument, to: selectedRange.start)
        
        let afterCusorRange = text.index(text.startIndex, offsetBy: cursorPosition)..<text.index(text.endIndex, offsetBy: 0)
        let afterCusorText = text[afterCusorRange]
        return String(afterCusorText)
    }
}

// MARK: - UI
extension WriteReviewViewController {
    private func configureSubViews() {
        writeReviewTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(writeReviewTextView)
    }
    
    private func setConstraintsOfWriteReviewTextView() {
        NSLayoutConstraint.activate([
            writeReviewTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            writeReviewTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            writeReviewTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            writeReviewTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])
    }
}

// MARK: - UITextViewDelegate
extension WriteReviewViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if getStringAfterCursor() != beforeCusorAfterString {
            keyboardIOManager.inputQueue.removeAll()
            keyboardIOManager.combinationQueue.removeAll()
            currentCombinationText = " "
            keyboardIOManager.isNewQueue = true
        }
        
        beforeCusorAfterString = getStringAfterCursor()
    }
}

