//
//  ARInteractionController.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 10/25/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import ARKit
import SceneKit

protocol ARVIRDelegate {
    func hasRegisteredPlane()
    func isShowingGhostWall(value: Bool)
    func isShowingGhostWork(value: Bool)
    func hasPlacedArtwork()
    func hasPlacedWall()
}

protocol ARVIRInteractive {
    func placeWall()
    func placeArtwork()
    func restart()
}

//State machine
public enum ARInteractionMode {
    case launching
    case detectedFloor
    case detectedFloorPostTransition
    case createdWall
    case placedOnWall
}

class ARInteractionController: NSObject, ARSCNViewDelegate, ARSessionDelegate {
    
    //Unitialized local members
    private let session: ARSession
    private let sceneView: ARSCNView
    private let delegate: ARVIRDelegate
    private let config: ARAugmentedRealityConfig
    
    //Mark -- Public
    public var state: ARInteractionMode = .launching
    
    private var pointCloudNode: SCNNode?
    
    private var detectedPlanes = [SCNNode]()
    private var invisibleFloors = [SCNNode]()
    
    //The clipped line of the wall while you are setting up
    private var ghostWallLine: SCNNode?
    //So we can animate it out on the first time
    private var hasShownGhostWallLineOnce = false
    
    //Full version of the wall which you fire the artwork at
    private var wall: SCNNode?
    
    //The final version of the artwork shown on a wall
    private var artwork: SCNNode?
    
    //The wip version of the artwork placed on the wall above
    private var ghostwork: SCNNode?
    
    private var pointOnScreenForArtworkProjection = CGPoint(x: UIScreen.main.bounds.width / 2, y: (UIScreen.main.bounds.height - 221) / 2)
    private var pointOnScreenForWallProjection = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    
    public init(config: ARAugmentedRealityConfig, session: ARSession, sceneView: ARSCNView, delegate: ARVIRDelegate) {
        self.config = config
        self.session = session
        self.sceneView = sceneView
        self.delegate = delegate
    }
    
    public func setState(state: ARInteractionMode) {
        self.state = state
        
        switch state {
        case .launching: break
        case .detectedFloor:
            self.delegate.hasRegisteredPlane()
            self.vibrate(style: .heavy)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.state = .detectedFloorPostTransition
            }
            
        case .detectedFloorPostTransition:
            self.fadeOutPointCloud()
        case .createdWall:
            self.delegate.hasPlacedWall()
            self.vibrate(style: .heavy)
        case .placedOnWall:
            self.delegate.hasPlacedArtwork()
            self.vibrate(style: .heavy)
        }
    }
    
    private func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impact = UIImpactFeedbackGenerator(style: style)
        impact.prepare()
        impact.impactOccurred()
    }
    
    //Not yet implemented
    private func fadeOutPointCloud() {
        let fade = SCNAction()
        fade.duration = 0.6
        self.pointCloudNode?.runAction(fade, completionHandler: {
            if self.pointCloudNode != nil {
                self.pointCloudNode?.removeFromParentNode()
                self.pointCloudNode = nil
            }
        })
    }
    
    private func renderWhileFindindFloor(frame: ARFrame) {
        guard let pointCount = frame.rawFeaturePoints?.points.count else { return }
        
        // We want a root node to work in, it's going to hold the all of the represented spheres
        // that come together to make the point cloud
        if !(self.pointCloudNode != nil) {
            self.pointCloudNode = SCNNode()
            self.sceneView.scene.rootNode.addChildNode(self.pointCloudNode!) //force unwrap
        }
        
        //Add color
        let whiteMaterial = SCNMaterial()
        whiteMaterial.diffuse.contents = UIColor.white
        whiteMaterial.locksAmbientWithDiffuse = true
        
        //Remove old point clouds
        for child in self.pointCloudNode!.childNodes {
            child.removeFromParentNode()
        }
        
        //Use the frames point clouds to create a set of SCNSpheres
        //Which live at the feature point in the AR world
        for i in 0..<pointCount {
            guard let point = frame.rawFeaturePoints?.points[i] else { return }
            let vector = SCNVector3Make(point[0], point[1], point[2])
            
            let pointSphere = SCNSphere(radius: 0.002)
            pointSphere.materials = [whiteMaterial]
            
            let pointNode = SCNNode(geometry: pointSphere)
            pointNode.position = vector
            
            self.pointCloudNode?.addChildNode(pointNode)
        }
    }
    
    private func renderWhenPlacingWall(frame: ARFrame) {
        let options: [SCNHitTestOption: Any] = [SCNHitTestOption.ignoreHiddenNodes: false, SCNHitTestOption.firstFoundOnly: true, SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue, SCNHitTestOption.backFaceCulling: false]
        let results = self.sceneView.hitTest(self.pointOnScreenForWallProjection, options: options)
        
        for result in results {
            if self.invisibleFloors.contains(result.node) {
                if (self.ghostWallLine == nil) {
                    //Create a ghostwall if we dont have one already
                    let ghostBox = ARSCNWallNode.shortWallNode()
                    let ghostWall = SCNNode(geometry: ghostBox)
                    ghostWall.opacity = 0.8
                    
                    result.node.addChildNode(ghostWall)
                    
                    let lookAtCamera = SCNLookAtConstraint(target: self.sceneView.pointOfView)
                    lookAtCamera.isGimbalLockEnabled = true
                    ghostWall.constraints = [lookAtCamera]
                    
                    self.ghostWallLine = ghostWall
                    
                    //Handle a one of animation
                    if !self.hasShownGhostWallLineOnce {
                        self.hasShownGhostWallLineOnce = true
                        ghostBox.width = 0.01
                        
                        let animation = CABasicAnimation(keyPath: "width")
                        animation.fromValue = 0.01
                        animation.toValue = 10
                        animation.duration = 5
                        animation.autoreverses = false
                        animation.repeatCount = 0
                        ghostBox.addAnimation(animation, forKey: "width")
                        
                        ghostBox.width = 10
                    }
                }
            }
            
            SCNTransaction.animationDuration = 0.1
            self.ghostWallLine?.position = result.localCoordinates
            self.delegate.isShowingGhostWall(value: true)
            return
        }
        
        if self.ghostWallLine != nil {
            self.delegate.isShowingGhostWall(value: false)
            self.ghostWallLine?.removeFromParentNode()
            self.ghostWallLine = nil
        }
    }
    
    private func renderWhenPlacingArtwork(frame: ARFrame) {
        let options: [SCNHitTestOption: Any] = [SCNHitTestOption.ignoreHiddenNodes: false, SCNHitTestOption.firstFoundOnly: true, SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue, SCNHitTestOption.backFaceCulling: false]
        let results = self.sceneView.hitTest(self.pointOnScreenForArtworkProjection, options: options)
        
        for result in results {
            guard self.wall != nil else { return }
            
            if (self.wall?.isEqual(result.node))! {
                //Create ghost art work
                if (self.ghostwork == nil) {
                    //Artwork + outline live inside this node
                    let rootNode = SCNNode()
                    rootNode.position = result.localCoordinates
                    rootNode.eulerAngles = SCNVector3Make(0, 0, Float(-Double.pi))
                    
                    let box = SCNArtworkNode(nodeWith: self.config)
                    let artwork = SCNNode(geometry: box)
                    artwork.opacity = 0.5
                    
                    let outline = SCNArtworkNode.ghostOutlineNode(with: self.config)
                    rootNode.addChildNode(outline)
                    rootNode.addChildNode(artwork)
                    result.node.addChildNode(rootNode)
                    
                    self.ghostwork = rootNode
                }
                
                self.ghostwork?.position = result.localCoordinates
                self.delegate.isShowingGhostWork(value: true)
                return
            }
        }
        
        if self.ghostwork != nil {
            self.delegate.isShowingGhostWork(value: false)
            self.ghostwork?.removeFromParentNode()
            self.ghostwork = nil
        }
    }
    
    private func invisibleWallNodeForPlaneAnchor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let hiddenPlane = SCNPlane(width: 64, height: 64)
        hiddenPlane.firstMaterial?.diffuse.contents = UIColor.clear
        
        let hittablePlane = SCNNode(geometry: hiddenPlane)
        let wallCenter = SCNVector3.init(planeAnchor.center)
        
        hittablePlane.position = wallCenter
        hittablePlane.eulerAngles = SCNVector3Make(Float(-Double.pi / 2), 0, 0)
        
        return hittablePlane
    }
}

//Implement ARVIRDelegate
extension ARInteractionController: ARVIRInteractive {
    
    public func placeWall() {
        let options: [SCNHitTestOption: Any] = [SCNHitTestOption.ignoreHiddenNodes: false, SCNHitTestOption.firstFoundOnly: true, SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue]
        let results = self.sceneView.hitTest(self.pointOnScreenForWallProjection, options: options)
        
        for result in results {
            //When you want to place the invisible wall. based on the curernt ghostwall
            if (self.wall == nil && self.invisibleFloors.contains(result.node)) {
                
                let wall = ARSCNWallNode.fullWallNode()
                let userWall = SCNNode(geometry: wall)
                result.node.addChildNode(userWall)
                
                userWall.position = result.localCoordinates
                userWall.eulerAngles = SCNVector3Make(-.pi / 2, 0, 0)
                
                guard let userPosition = self.sceneView.pointOfView?.position else { return }
                let bottomPosition = SCNVector3Make(userPosition.x, result.worldCoordinates.y, userPosition.z)
                userWall.look(at: bottomPosition)
                
                userWall.position = SCNVector3Make(userWall.position.x, userWall.position.y, userWall.position.z + 4 / 2)
                self.wall = userWall
                self.state = .createdWall
                return
            }
        }
    }
    
    internal func placeArtwork() {
        let options: [SCNHitTestOption: Any] = [SCNHitTestOption.ignoreHiddenNodes: false, SCNHitTestOption.firstFoundOnly: true, SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue]
        let results = self.sceneView.hitTest(self.pointOnScreenForArtworkProjection, options: options)
        
        for result in results {
            
            //When you want to place down artwork
            if result.node.isEqual(self.wall) {
                let shadowBox = SCNArtworkNode(shadowNodeWith: self.config)
                let shadow = SCNNode(geometry: shadowBox)
                
                // Offset the shadow back a bit (behind the work)
                // and down a bit to imply a higher light source
                shadow.position =  SCNVector3Make(result.localCoordinates.x, result.localCoordinates.y, result.localCoordinates.z + Float(shadowBox.length / 2));
                shadow.opacity = 0.4;
                shadow.eulerAngles = SCNVector3Make(0, 0, Float(-Double.pi));
                result.node.addChildNode(shadow)
                
                let box = SCNArtworkNode(nodeWith: self.config)
                let artWork = SCNNode(geometry: box)
                artWork.position = result.localCoordinates
                artWork.eulerAngles = SCNVector3Make(0, 0, Float(-Double.pi))
                result.node.addChildNode(artWork)
                
                self.artwork = artWork
                self.ghostWallLine?.removeFromParentNode()
                self.ghostwork?.removeFromParentNode()
                
                self.state = .placedOnWall
                return
            }
        }
    }
    
    internal func restart() {
        self.hasShownGhostWallLineOnce = false
        self.state = .launching
        
        let bounds = UIScreen.main.bounds
        self.pointOnScreenForWallProjection = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        self.pointOnScreenForArtworkProjection = CGPoint(x: bounds.size.width / 2, y: (bounds.size.height - 221) / 2)
        
        self.detectedPlanes = []
        self.invisibleFloors = []
        
        self.pointCloudNode?.removeFromParentNode()
        self.pointCloudNode = nil
        
        self.ghostWallLine?.removeFromParentNode()
        self.ghostWallLine = nil
        
        self.wall?.removeFromParentNode()
        self.wall = nil
        
        self.artwork?.removeFromParentNode()
        self.artwork = nil
        
        self.ghostwork?.removeFromParentNode()
        self.ghostwork = nil
        
        //Warning force unwrap!
        self.session.run(self.session.configuration!)
    }
}

//Implement ARSCNViewDelegate and ARSessionDelegate methods
extension ARInteractionController {
    internal func session(_ session: ARSession, didUpdate frame: ARFrame) {
        switch self.state {
        case .launching: self.renderWhileFindindFloor(frame: frame)
        case .detectedFloor: self.renderWhileFindindFloor(frame: frame)
        case .detectedFloorPostTransition: self.renderWhenPlacingWall(frame: frame)
        case .createdWall: self.renderWhenPlacingArtwork(frame: frame)
        case .placedOnWall: break
        }
    }
    
    //Used to update and realign plane
    internal func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        SCNTransaction.animationDuration = 0.1
        
        //Custom
        for planeNode in node.childNodes {
            guard let plane = planeNode.geometry as? SCNPlane else {
                return
            }
            if self.detectedPlanes.contains(planeNode) {
                plane.width = CGFloat(planeAnchor.extent.x)
                plane.height = CGFloat(planeAnchor.extent.y)
                planeNode.position = SCNVector3.init(planeAnchor.center)
            }
            
            if self.invisibleFloors.contains(planeNode) {
                planeNode.position = SCNVector3.init(planeAnchor.center)
            }
        }
    }
    
    internal func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal, self.invisibleFloors.count == 0 else { return }
        //if self.state == .launching { self.state = .detectedFloor }
        
        //Create an anchor node, which can get moved around as we become more sure of where the plane actually is
        let wallNode = self.invisibleWallNodeForPlaneAnchor(planeAnchor: planeAnchor)
        node.addChildNode(wallNode)
        self.invisibleFloors.append(wallNode)
        
        if self.state == .launching { self.setState(state: .detectedFloor)}
    }
}
