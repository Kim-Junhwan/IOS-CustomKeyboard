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
        keyboardIOManager.updateTextView = { [weak self] in
            self?.writeReviewTextView.text = $0
        }
        view.backgroundColor = .systemBackground
        configureSubViews()
        setConstraintsOfWriteReviewTextView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.sendReviewMessage(review: writeReviewTextView.text)
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
