//
//  ArtCollectionViewCell.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 10/31/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit

class ArtCollectionViewCell: UICollectionViewCell {
    
    public let artImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "San Francisco", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 4
        
        //Configure subviews
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(name: String, image: UIImage) {
        self.nameLabel.text = name
        self.artImage.image = image
    }
}

//Setup UI
extension ArtCollectionViewCell {
    private func setupView() {
        
        //Setup image view
        self.addSubview(artImage)
        NSLayoutConstraint.activate([
            self.artImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            self.artImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            self.artImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            self.artImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40)
        ])
        
        //Setup name label
        self.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            self.nameLabel.topAnchor.constraint(equalTo: self.artImage.bottomAnchor),
            self.nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
        
    }
}
