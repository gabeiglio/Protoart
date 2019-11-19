//
//  ARAugmentedRealityConfig.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 10/25/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit

class ARAugmentedRealityConfig {
    public let image: UIImage
    public let size: CGSize
    public let depth: CGFloat
    
    public init(with image: UIImage, size: CGSize) {
        self.image = image
        self.size = size
        self.depth = 0.02
    }
    
    public init(with image: UIImage, size: CGSize, depth: CGFloat) {
        self.image = image
        self.size = size
        self.depth = depth
    }
}
