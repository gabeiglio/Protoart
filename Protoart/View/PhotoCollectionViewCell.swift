//
//  PhotoCollectionViewCell.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 10/31/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    public let photoImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont(name: "San Francisco", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
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
        self.photoImage.image = image
    }
}

//Setup UI
extension PhotoCollectionViewCell {
    private func setupView() {
        
        //Setup image view
        self.addSubview(photoImage)
        NSLayoutConstraint.activate([
            self.photoImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.photoImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            self.photoImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            self.photoImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        
        //Setup name label
        self.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            self.nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5),
            self.nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 5),
            self.nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            self.nameLabel.heightAnchor.constraint(equalToConstant: 30)
        ])

    }
}
