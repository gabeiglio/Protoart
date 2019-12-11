//
//  MainHeaderView.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 12/11/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit

protocol MainHeaderDelegate {
    func seeMorePressed(key: String)
}

class MainHeaderView: UICollectionReusableView {
    private let labelTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton()
        button.setTitle("See more", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public var delegate: MainHeaderDelegate?
    private var key: String = ""
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(labelTitle)
        NSLayoutConstraint.activate([
            self.labelTitle.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5),
            self.labelTitle.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -5),
            self.labelTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            self.labelTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 5)
        ])
        
        self.addSubview(moreButton)
        NSLayoutConstraint.activate([
            self.moreButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5),
            self.moreButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            self.moreButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            self.moreButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        self.moreButton.addTarget(self, action: #selector(seeMorePressed), for: .touchUpInside)
    }
    
    @objc public func seeMorePressed() {
        delegate?.seeMorePressed(key: self.key)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(title: String, key: String) {
        self.labelTitle.text = title
        self.key = key
    }
}
