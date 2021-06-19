//
//  CustomTextField.swift
//  CustomTextFieldApp
//
//  Created by Arie Peretz on 18/06/2021.
//

import UIKit
import SwiftUI

class CustomTextField: UITextField {
    var didEnterLastDigit: ((String)->Void)?
    
    private var isConfigured: Bool = false
    private var digitLabels = [UILabel]()
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recognizer
    }()
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIScreen.main.bounds.width - 40.0, height: 55.0)
    }
    
    func configure(with slotCount: Int = 5) {
        guard isConfigured == false else { return }
        isConfigured.toggle()
        configureTextField()
                
        let labelsStackView = createLabelsStackView(with: slotCount)
        addSubview(labelsStackView)
        addGestureRecognizer(tapRecognizer)
        
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: topAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configureTextField() {
        tintColor = .clear
        textColor = .clear
        keyboardType = .numberPad
        textContentType = .oneTimeCode
        addTarget(self, action: #selector(CustomTextField.textFieldDidChange(_:)), for: .editingChanged)
        delegate = self
    }
    
    private func createLabelsStackView(with count: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        for _ in 1...count {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 40)
            label.isUserInteractionEnabled = true
            
            let blackView = UIView()
            blackView.translatesAutoresizingMaskIntoConstraints = false
            blackView.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
            blackView.backgroundColor = .black
            
            let labelStack = UIStackView()
            labelStack.axis = .vertical
            labelStack.alignment = .fill
            labelStack.distribution = .fill
            labelStack.spacing = 3.0
            labelStack.translatesAutoresizingMaskIntoConstraints = false
            labelStack.addArrangedSubview(label)
            labelStack.addArrangedSubview(blackView)
            
            stackView.addArrangedSubview(labelStack)
            digitLabels.append(label)
        }
        
        return stackView
    }
    
    @objc
    func textFieldDidChange(_ textField: CustomTextField) {
        print("text field did change internal function")
        guard let text = self.text, text.count <= digitLabels.count else { return }
        for i in 0..<digitLabels.count {
            let currentLabel = digitLabels[i]
            if i < text.count {
                let index = text.index(text.startIndex, offsetBy: i)
                currentLabel.text = String(text[index])
            } else {
                currentLabel.text?.removeAll()
            }
        }
        
        if text.count == digitLabels.count {
            didEnterLastDigit?(text)
        }
    }
}

extension CustomTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let characterCount = textField.text?.count else { return false }
        return characterCount < digitLabels.count || string == ""
    }
}

struct CustomTextFieldComponent: UIViewRepresentable {
    @Binding var input: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> CustomTextField {
        let view = CustomTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(with: 5)
        view.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        return view
    }
    
    func updateUIView(_ uiView: CustomTextField, context: Context) {
        uiView.text = input
    }
}

extension CustomTextFieldComponent {
    class Coordinator: NSObject {
        var component: CustomTextFieldComponent
        
        init(_ component: CustomTextFieldComponent) {
            self.component = component
        }
        
        @objc
        func textFieldDidChange(_ textField: CustomTextField) {
            print("text field did change external function")
            component.input = textField.text ?? ""
        }
    }
}
