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
    
    // MARK: - ViewProperties
    private lazy var writeReviewTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        guard let loadNib = Bundle.main.loadNibNamed("CustomKeyboardView", owner: nil)?.first as? CustomKeyboardView else { return textView}
        loadNib.delegate = keyboardIOManager
        textView.inputView = loadNib
        textView.becomeFirstResponder()
        
        return textView
    }()
    private var keyboardViewHeight: CGFloat?
    
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
        // 입력시
        keyboardIOManager.inputCaracter = { [weak self] in
            guard let self = self else { return }
            if $0 != " " {
                guard let outputCount = self.writeReviewTextView.text
                    .components(separatedBy: " ").last?.count else { return }
                (0..<outputCount).forEach { _ in
                    if !self.writeReviewTextView.text.isEmpty {
                        self.writeReviewTextView.deleteBackward()
                    }
                }
            }
            self.writeReviewTextView.insertText($0)
        }
        
        //삭제시
        keyboardIOManager.deleteCaracter = { [weak self] in
            guard let self = self else { return }
            
            if !self.writeReviewTextView.text.isEmpty {
                if $0 == "" {
                    self.writeReviewTextView.deleteBackward()
                } else {
                    self.writeReviewTextView.text.removeLast()
                    self.writeReviewTextView.insertText($0)
                }
            }
        }
    }
    
    /// 텍스트뷰의 커서 앞의 문자 가져오기
    func characterBeforeCursor() -> String? {
        if let cursorRange = writeReviewTextView.selectedTextRange {
            if let newPosition = writeReviewTextView.position(from: cursorRange.start, offset: -1) {
                let range = writeReviewTextView.textRange(from: newPosition, to: cursorRange.start)
                return writeReviewTextView.text(in: range!)
            }
        }
        return nil
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

extension WriteReviewViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let beforeCursorCharacter = characterBeforeCursor() else { return }
        keyboardIOManager.textViewBeforeCursorCharectar = beforeCursorCharacter
    }
}
