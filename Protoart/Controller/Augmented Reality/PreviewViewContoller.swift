//
//  PreviewViewContoller.swift
//  Protoart
//
//  Created by Gabriel Igliozzi on 10/21/19.
//  Copyright © 2019 Gabriel Igliozzi. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class PreviewViewController: UIViewController {
    
    private let sceneView = ARSCNView()
    private let tutorialView = TutorialView()
    private var interactionController: ARInteractionController!
    
    private let cameraTigger: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        view.layer.cornerRadius = 70 / 2
        return view
    }()
    
    public func initWith(config: ARAugmentedRealityConfig) {
        self.interactionController = ARInteractionController(config: config, session: self.sceneView.session, sceneView: self.sceneView, delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make screen not to idle when not active
        UIApplication.shared.isIdleTimerDisabled = true
        
        //Delegates
        self.sceneView.delegate = self
        self.sceneView.scene = SCNScene()
        self.sceneView.session.delegate = self

        //Crate Scene
        let scene = SCNScene()
        self.sceneView.scene = scene
        
        //Init
        self.setupView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.setupTutorial(with: "Focus the floor and move the Phone in a circular motion", buttonTitle: nil) {}
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.sceneView.session.pause()
    }

}

//Implement custom delegatees ARVIRDelegate
extension PreviewViewController: ARVIRDelegate {
    internal func hasRegisteredPlane() {
        self.interactionController.setState(state: .detectedFloorPostTransition)
        self.setupTutorial(with: "Place marker where the wall meets the floor", buttonTitle: "Place Marker") {
            self.interactionController.placeWall()
        }
    }
    
    internal func isShowingGhostWall(value: Bool) {}
    
    internal func isShowingGhostWork(value: Bool) {
        if value {
            self.setupTutorial(with: "Move the phone around to place the artwork", buttonTitle: "Place Artwork") {
                self.interactionController.placeArtwork()
                self.interactionController.setState(state: .placedOnWall)
            }
        }
    }
    
    internal func hasPlacedArtwork() {
        self.setupTutorial(with: "Succes!, Walk around to appreciate the Art work!.", buttonTitle: nil) {}
        
        UIView.animate(withDuration: 3) {
            self.tutorialView.alpha = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.tutorialView.removeFromSuperview()
            self.cameraTigger.isHidden = false
        }
    }
    
    internal func hasPlacedWall() {}
    
}

//Implement ARSCNViewDelegate
extension PreviewViewController: ARSCNViewDelegate, ARSessionDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        self.interactionController.renderer(renderer, didAdd: node, for: anchor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        self.interactionController.renderer(renderer, didUpdate: node, for: anchor)
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.interactionController.session(session, didUpdate: frame)
    }
}

//Handle tutorial and taking pictures
extension PreviewViewController {
    private func setupTutorial(with title: String, buttonTitle: String?, action: @escaping () -> ()) {
        self.tutorialView.updateValues(with: title, titleButton: buttonTitle)
        self.tutorialView.updateAction(action: action)
    }
    
    @objc private func takeSnapshot() {
        //Take snapshot and save it to camera roll
        UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
        
        UIView.animate(withDuration: 0.2) {
            self.sceneView.alpha = 0
        }
        
        UIView.animate(withDuration: 0.2) {
            self.sceneView.alpha = 1
        }
    }
}

//Setup UI
extension PreviewViewController {
    private func setupView() {
        
        //Customize nav bar
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.navigationBar.tintColor = .white
        
        //add scene view to parent view
        self.sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sceneView)
        NSLayoutConstraint.activate([
            self.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        //Add tutorial view
        self.sceneView.addSubview(tutorialView)
        NSLayoutConstraint.activate([
            self.tutorialView.leftAnchor.constraint(equalTo: self.sceneView.leftAnchor),
            self.tutorialView.rightAnchor.constraint(equalTo: self.sceneView.rightAnchor),
            self.tutorialView.bottomAnchor.constraint(equalTo: self.sceneView.bottomAnchor),
            self.tutorialView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        //Add camera trigger
        self.sceneView.addSubview(cameraTigger)
        NSLayoutConstraint.activate([
            self.cameraTigger.bottomAnchor.constraint(equalTo: self.sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            self.cameraTigger.centerXAnchor.constraint(equalTo: self.sceneView.centerXAnchor, constant: 0),
            self.cameraTigger.widthAnchor.constraint(equalToConstant: 70),
            self.cameraTigger.heightAnchor.constraint(equalToConstant: 70)
        ])
        self.cameraTigger.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(takeSnapshot)))
        self.cameraTigger.isHidden = true
    }
}
