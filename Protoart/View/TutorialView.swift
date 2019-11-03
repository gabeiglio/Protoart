//
//  TutorialView.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 11/3/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit

class TutorialView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var action : () -> () = {}

            
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onButtonTap))
        self.actionButton.addGestureRecognizer(tapGesture)
        
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateValues(with title: String, titleButton: String?) {
        DispatchQueue.main.async {
            self.titleLabel.text = title
            
            if let buttonTitle = titleButton {
                self.actionButton.isHidden = false
                self.actionButton.setTitle(buttonTitle, for: .normal)
            } else {
                self.actionButton.isHidden = true
            }
        }
    }
    
    public func updateAction(action: @escaping () -> ()) {
        self.action = action
    }
    
    @objc public func onButtonTap() {
        self.action()
    }
    
}

//Setup UI
extension TutorialView {
    private func setupViews() {
        
        //Self
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        //Add button
        self.addSubview(actionButton)
        NSLayoutConstraint.activate([
            self.actionButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40),
            self.actionButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            self.actionButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            self.actionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        //Add titleLabel
        self.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            self.titleLabel.bottomAnchor.constraint(equalTo: self.actionButton.topAnchor, constant: -20),
            self.titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            self.titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20)
        ])
    }
}
