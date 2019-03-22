//
//  ViewController.swift
//  FindYourShip
//
//  Created by Weslie on 2019/3/22.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    var sceneView = ARSCNView()
    
    var updateCount = 0
    var planeNode: SCNNode?
    var scene: SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        self.view = sceneView
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//        
//        // Set the scene to the view
//        sceneView.scene = scene
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("""
                ARKit is not available on this device. For apps that require ARKit
                for core functionality, use the `arkit` key in the key in the
                `UIRequiredDeviceCapabilities` section of the Info.plist to prevent
                the app from installing. (If the app can't be installed, this error
                can't be triggered in a production scenario.)
                In apps where AR is an additive feature, use `isSupported` to
                determine whether to show UI for launching AR experiences.
            """)
        }
        resetAll()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if updateCount >= 50 {
            sceneView.debugOptions = []
            stopTracking()
            planeNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
            
            let scene = SCNScene(named: "art.scnassets/ship1.scn")!
            let ship = scene.rootNode
            ship.transform = SCNMatrix4MakeRotation(Float.pi / 2, 1, 0, 0)
//            ship.scale = SCNVector3(6, 6, 6)
            
            planeNode?.addChildNode(ship)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}

extension ViewController {
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    private func stopTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .init(rawValue: 0)
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
    }
    
    private func resetAll() {
        resetTracking()
        updateCount = 0
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func createPlaneNode(center: vector_float3, extent: vector_float3) -> SCNNode {
        
        let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.yellow.withAlphaComponent(0.4)
        plane.materials = [planeMaterial]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(center.x, 0, center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        return planeNode
    }
}

extension ViewController {
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("session didFailWithError: \(error.localizedDescription)")
        resetTracking()
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("sessionWasInterrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("sessionInterruptionEnded")
        resetTracking()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("session cameraDidChangeTrackingState")
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count < 1, updateCount < 1 {
            print("detected plane")
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            plane.firstMaterial?.diffuse.contents = UIColor.red
            
            let debugPlaneNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
            debugPlaneNode.name = "debugPlaneNode"
            
            planeNode = debugPlaneNode
            
            node.addChildNode(debugPlaneNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        updateCount += 1
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
}
