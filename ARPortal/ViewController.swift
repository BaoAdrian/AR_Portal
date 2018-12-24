//
//  ViewController.swift
//  ARPortal
//
//  Created by Adrian Bao on 12/23/18.
//  Copyright © 2018 Adrian Bao. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    

    @IBOutlet weak var planeDetected: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        
        // Detect Horizontal Planes
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        
        self.sceneView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else {return}
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        if !hitTestResult.isEmpty {
            // Add Room
            self.addPortal(hitTestResult: hitTestResult.first!)
        } else {
            // Let the user know that a surface was not detected
            // NOT A VALID SURFACE TOAST
        }
    }
    
    func addPortal(hitTestResult: ARHitTestResult) {
        let portalScene = SCNScene(named: "Portal.scnassets/Portal.scn")
        
        // Load node inside the scene
        let portalNode = portalScene!.rootNode.childNode(withName: "Portal", recursively: false)
        
        
        // Pull positions
        let transform = hitTestResult.worldTransform
        let planeXPosition = transform.columns.3.x
        let planeYPosition = transform.columns.3.y
        let planeZPosition = transform.columns.3.y
        
        portalNode!.position = SCNVector3(planeXPosition, planeYPosition, planeZPosition)
        self.sceneView.scene.rootNode.addChildNode(portalNode!)
        
        // Add images to the inside of the virtual environment
        self.addPlane(nodeName: "roof", portalNode: portalNode!, imageName: "top")
        self.addPlane(nodeName: "floor", portalNode: portalNode!, imageName: "bottom")
        self.addWalls(nodeName: "backWall", portalNode: portalNode!, imageName: "back")
        self.addWalls(nodeName: "sideWallA", portalNode: portalNode!, imageName: "sideA")
        self.addWalls(nodeName: "sideWallB", portalNode: portalNode!, imageName: "sideB")
        self.addWalls(nodeName: "sideDoorA", portalNode: portalNode!, imageName: "sideDoorA")
        self.addWalls(nodeName: "sideDoorB", portalNode: portalNode!, imageName: "sideDoorB")
        
        
    }

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {return}
        
        DispatchQueue.main.async {
            self.planeDetected.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.planeDetected.isHidden = true
        }
    }
    
    func addWalls(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true) // Recursion needed since the roof and floor are child nodes
        
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).png")
        
        // Loads the transluscent mask rendered before the opaque walls
        child?.renderingOrder = 200
        
        if let mask = child?.childNode(withName: "mask", recursively: false) {
            mask.geometry?.firstMaterial?.transparency = 0.000001
        }
    }
    
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        let child = portalNode.childNode(withName: nodeName, recursively: true) // Recursion needed since the roof and floor are child nodes
        
        child?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "Portal.scnassets/\(imageName).png")
        
        // Give renderingOrder change for planes so the mask can provide the invisible illusion
        child?.renderingOrder = 200
    }
    
    
}

