//
//  ARSCNWallNode.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 10/25/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import SceneKit

class ARSCNWallNode {
    
    static public func shortWallNode() -> SCNBox {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        material.locksAmbientWithDiffuse = true
        material.lightingModel = SCNMaterial.LightingModel.constant
        
        let box = SCNBox(width: 10, height: 0.01, length: 0.01, chamferRadius: 0)
        box.materials = [material, material, material, material, material, material]
        return box
    }
    
    static public func fullWallNode() -> SCNBox {
        
        //Sides
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue.withAlphaComponent(0)
        material.locksAmbientWithDiffuse = true
        
        //Back / Front
        let frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents = UIColor.green.withAlphaComponent(0)
        frontMaterial.locksAmbientWithDiffuse = true
        
        material.lightingModel = SCNMaterial.LightingModel.constant
        
        let box = SCNBox(width: 20, height: 5, length: 0.1, chamferRadius: 0)
        box.materials = [material, frontMaterial, material, material, material, material]
        
        return box
    }
    
}
