//
//  Art.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 10/31/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit

class Art {
    public let name: String
    public let image: UIImage
    public let size: CGSize
    
    public init(name: String, image: UIImage, size: CGSize) {
        self.name = name
        self.image = image
        self.size = size
    }
    
    public static func getArt() -> [Art] {
        var data = [Art]()
        data.append(Art(name: "Mona Lisa", image: UIImage(named: "monalisa")!, size: CGSize(width: 0.23, height: 0.28)))
        data.append(Art(name: "Avila", image: UIImage(named: "avila")!, size: CGSize(width: 0.9, height: 0.3)))
        data.append(Art(name: "Iris", image: UIImage(named: "iris")!, size: CGSize(width: 0.37, height: 0.28)))
        data.append(Art(name: "City Skyline", image: UIImage(named: "city")!, size: CGSize(width: 1.62, height: 1.01)))
        data.append(Art(name: "Albert Einstein", image: UIImage(named: "einstein")!, size: CGSize(width: 0.31, height: 0.16)))
        data.append(Art(name: "The Scream", image: UIImage(named: "elgrito")!, size: CGSize(width: 0.9, height: 0.10)))
        data.append(Art(name: "Pathway", image: UIImage(named: "pathway")!, size: CGSize(width: 0.1016, height: 0.1025)))
        data.append(Art(name: "Abstract Women", image: UIImage(named: "women")!, size: CGSize(width: 0.1212, height: 0.1212)))
        return data
    }
 }
