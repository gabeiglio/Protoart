//
//  SCNArtworkNode.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 10/25/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import SceneKit

class SCNArtworkNode: SCNBox {
    
    public init(boxWith config: ARAugmentedRealityConfig) {
        super.init()
        self.width = config.size.width
        self.height = config.size.height
        self.length = config.depth
        self.chamferRadius = 0
    }
    
    public init(nodeWith config: ARAugmentedRealityConfig) {
        super.init()
        
        //Sides / Back
        let blackMaterial = SCNMaterial()
        blackMaterial.diffuse.contents = UIColor.black
        blackMaterial.locksAmbientWithDiffuse = true
        
        //Front
        let imageMaterial = SCNMaterial()
        imageMaterial.diffuse.contents = config.image
        imageMaterial.locksAmbientWithDiffuse = true
        imageMaterial.lightingModel = SCNMaterial.LightingModel.physicallyBased
        
        //Init
        self.width = config.size.width
        self.height = config.size.height
        self.length = config.depth
        self.chamferRadius = 0
        
        self.materials = [blackMaterial, blackMaterial, imageMaterial, blackMaterial, blackMaterial, blackMaterial]
        self.name = "Artwork"
    }
    
    public init(shadowNodeWith config: ARAugmentedRealityConfig) {
        super.init()
        
        self.width = config.size.width + 0.02
        self.height = config.size.height + 0.02
        self.length = 0.01
        self.chamferRadius = 0
        
        //Sides / Back
        let clearMaterial = SCNMaterial()
        clearMaterial.diffuse.contents = UIColor.clear
        
        //Front
        let imageMaterial = SCNMaterial()
        imageMaterial.diffuse.contents = config.image
        imageMaterial.locksAmbientWithDiffuse = true
        imageMaterial.lightingModel = SCNMaterial.LightingModel.physicallyBased
        
        self.materials = [clearMaterial, clearMaterial, imageMaterial, clearMaterial, clearMaterial, clearMaterial]
        self.name = "Artwork Shadow"
    }
    
    static public func ghostOutlineNode(with config: ARAugmentedRealityConfig) -> SCNNode {
        
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = UIColor.white
        whiteMaterial.locksAmbientWithDiffuse = true
        
        let materials = [whiteMaterial, whiteMaterial, whiteMaterial, whiteMaterial, whiteMaterial,whiteMaterial]
        let width = config.size.width
        let height = config.size.height
        let distance: CGFloat = 0.001
        let nonOrdinalLength: CGFloat = 0.01 //e.g the sides
        
        let top = SCNBox(width: width + nonOrdinalLength, height: nonOrdinalLength, length: nonOrdinalLength, chamferRadius: 0)
        top.materials = materials
        let topNode = SCNNode(geometry: top)
        topNode.position = SCNVector3Make(0, Float(-(height/2) + distance), 0)
        
        let bottom = SCNBox(width: width + nonOrdinalLength, height: nonOrdinalLength, length: nonOrdinalLength, chamferRadius: 0)
        bottom.materials = materials
        let bottomNode = SCNNode(geometry: bottom)
        bottomNode.position = SCNVector3Make(0, Float((height/2) + distance), 0)
        
        let left = SCNBox(width: nonOrdinalLength, height: height + nonOrdinalLength, length: nonOrdinalLength, chamferRadius: 0)
        left.materials = materials
        let leftNode = SCNNode(geometry: left)
        leftNode.position = SCNVector3Make(Float(width / 2 + distance), 0, 0)
        
        let right = SCNBox(width: nonOrdinalLength, height: height + nonOrdinalLength, length: nonOrdinalLength, chamferRadius: 0)
        right.materials = materials
        let rightNode = SCNNode(geometry: right)
        rightNode.position = SCNVector3Make(Float(-width/2 - distance), 0, 0)
        
        let hostNode = SCNNode()
        hostNode.addChildNode(topNode)
        hostNode.addChildNode(bottomNode)
        hostNode.addChildNode(leftNode)
        hostNode.addChildNode(rightNode)
        
        return hostNode
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
