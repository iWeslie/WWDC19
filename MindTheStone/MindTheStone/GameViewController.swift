//
//  GameViewController.swift
//  MindTheStone
//
//  Created by Weslie on 2019/3/17.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class GameViewController: UIViewController {
	
	public var sceneView: ARSCNView = ARSCNView()
	
//	var baseNode: SCNNode?
	var planeNode: SCNNode?
	var gameNode:SCNNode?

	var updateCount = 0
	
	var playBtn: UIButton?
	var hudImg: UIImageView?
	
	var scene: SCNScene!
	var wallNode: SCNNode!
	
	var viewCenter: CGPoint {
		let viewBounds = view.bounds
		return CGPoint(x: viewBounds.width / 2.0, y: viewBounds.height / 2.0)
	}
	
	private var stones = Set<StoneNode>()
	
	private lazy var stoneGenerator: Timer = {
		return Timer(timeInterval: 1.0, repeats: true) {_ in 
			self.spawnStone()
		}
	}()
	
	private lazy var coinGenerator: Timer = {
		return Timer(timeInterval: 5.0, repeats: true) {_ in
			self.spawnCoin()
		}
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = sceneView
        
//        sceneView.clipsToBounds = true
//        sceneView.translatesAutoresizingMaskIntoConstraints = false
        
//        NSLayoutConstraint.activate([
//            sceneView.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor),
//            sceneView.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor),
//            sceneView.topAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.topAnchor),
//            sceneView.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor)
//            ])
        
        sceneView.delegate = self
		sceneView.scene.physicsWorld.contactDelegate = self
//        let scene = SCNScene(named: "art.scnassets/Scene/GameScene.scn")!
        scene = sceneView.scene
		
		sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
		
		setupHUD()
		setupShip()
		
        // allows the user to manipulate the camera
//        sceneView.allowsCameraControl = true
		
        // show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
	
//	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		if let hit = sceneView.hitTest(viewCenter, types: [.existingPlaneUsingExtent]).first {
//			sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
//		}
//	}
	
    func testNode() {
        let stone = SCNScene(named: "art.scnassets/Scene/GameScene.scn")!
        sceneView.scene = stone
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
	
	func setupShip() {
		
	}
	
	func setupTimer() {
		DispatchQueue.main.async {
			RunLoop.main.add(self.stoneGenerator, forMode: RunLoop.Mode.common)
			RunLoop.main.add(self.coinGenerator, forMode: RunLoop.Mode.common)
		}
	}
	
	@objc func fireLazer() {
		
		let geometry = SCNSphere(radius: 0.1)
		geometry.firstMaterial?.diffuse.contents = UIColor.blue

		let geometryNode = SCNNode(geometry: geometry)
		
		geometryNode.position = SCNVector3(x: 6, y: 4, z: 0)
		
		let lazer = SCNParticleSystem(named: "lazer.scnp", inDirectory: nil)!
		
		let force = SCNVector3(x: 0, y: 0 , z: 0)
		geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		geometryNode.physicsBody?.applyForce(force, asImpulse: true)
		geometryNode.physicsBody?.isAffectedByGravity = false
		
		geometryNode.addParticleSystem(lazer)

		
		scene.rootNode.addChildNode(geometryNode)
	}
	
	func setupHUD() {
		let screenFrame = UIScreen.main.bounds
		let centerPosition = CGPoint(x: screenFrame.width / 2 - 15, y: screenFrame.height / 2  - 15)
		let hudImg = UIImageView(frame: CGRect(origin: centerPosition, size: CGSize(width: 30, height: 30)))
		hudImg.image = UIImage(named: "hud")
		hudImg.contentMode = .scaleAspectFit
		self.view.addSubview(hudImg)
		
		playBtn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
		playBtn?.setTitle("Play", for: .normal)
		playBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 30)
		playBtn?.titleLabel?.textColor = UIColor.red
		playBtn?.addTarget(self, action: #selector(playBtnClicked), for: .touchUpInside)
		self.view.addSubview(playBtn!)
		
		playBtn?.isHidden = true
		
	}
	
	@objc func playBtnClicked() {
		sceneView.debugOptions = []
		stopTracking()
		setupTimer()
		
		planeNode?.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
		
		let skyPlane = SCNPlane(width: 30, height: 24)
		skyPlane.firstMaterial?.diffuse.contents = UIImage(named: "sky.jpg")
		let skyNode = SCNNode(geometry: skyPlane)
		sceneView.scene.rootNode.addChildNode(skyNode)
		skyNode.position = SCNVector3(x: 0, y: 0, z: -10)

 
	}
	
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		let (direction, currentVector) = fetchUserLocation(in: self.sceneView.session.currentFrame)
		let geometryNode = LazerNode.fireLazer(acc: direction)
		geometryNode.position = currentVector
		geometryNode.physicsBody?.applyForce(direction * 20, asImpulse: true)
		scene.rootNode.addChildNode(geometryNode)
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

extension GameViewController: ARSCNViewDelegate {
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		if let planeAnchor = anchor as? ARPlaneAnchor, node.childNodes.count < 1, updateCount < 1 {
			print("detected plane")
			let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
			plane.firstMaterial?.diffuse.contents = UIColor.red
			
			let debugPlaneNode = createPlaneNode(center: planeAnchor.center, extent: planeAnchor.extent)
			debugPlaneNode.name = "debugPlaneNode"
			
			planeNode = debugPlaneNode
			
			node.addChildNode(debugPlaneNode)
//			self.debugPlanes.append(debugPlaneNode)
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
		guard let planeAnchor = anchor as? ARPlaneAnchor,
			let planeNode = node.childNodes.first,
			let plane = planeNode.geometry as? SCNPlane
			else { return }
		
		updateCount += 1
		
		
		if updateCount > 20 {
			DispatchQueue.main.async {
				self.playBtn?.isHidden = false
			}
		}
		
		
		// 平面的中心点可以会变动.
//		planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
		
		/*
		平面尺寸可能会变大,或者把几个小平面合并为一个大平面.合并时,`ARSCNView`自动删除同一个平面上的相应节点,然后调用该方法来更新保留的另一个平面的尺寸.(经过测试,合并时,保留第一个检测到的平面和对应节点)
		*/
		plane.width = CGFloat(planeAnchor.extent.x)
		plane.height = CGFloat(planeAnchor.extent.z)
	}
	

	// MARK: - ARSessionObserver
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

extension GameViewController: SCNSceneRendererDelegate {
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		for stone in stones {
			if stone.position.z > 1 {
				stones.remove(stone)
				stone.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
			}
		}
	}
}

extension GameViewController: SCNPhysicsContactDelegate {
	func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
		
		let lazerNode = contact.nodeB
		if lazerNode.physicsBody?.categoryBitMask == CollisionCategory.lazer.rawValue {
			lazerNode.removeFromParentNode()
			
			let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
			let systemNode = SCNNode()
			systemNode.addParticleSystem(particleSystem!)
			contact.nodeA.addChildNode(systemNode)
			contact.nodeA.physicsBody = SCNPhysicsBody()
			contact.nodeA.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
			
//			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
//				contact.nodeA.removeFromParentNode()
//			})
		}
		
	}
}

extension GameViewController {
	private func resetTracking() {
		let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = [.vertical, .horizontal]
		configuration.isLightEstimationEnabled = true
		sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
	}
	private func stopTracking() {
		let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = .init(rawValue: 0)
		configuration.isLightEstimationEnabled = true
		sceneView.session.run(configuration)
	}
	
	@objc private func resetAll() {
		resetTracking()
		updateCount = 0
		sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
	}
	
	private func spawnStone() {
		
		guard let planeNode = planeNode else { return }
		let x = Float.random(in: -3...3)
		let y = Float.random(in: -3...3)
		let z = planeNode.position.z - 8
		
		let stoneNode = StoneNode.spawnStone()
		stoneNode.position = SCNVector3(x, y, z)
		
		self.stones.insert(stoneNode)
		
		
		let randomOffsetForce = CGFloat.random(in: -0.01...0.01)
		stoneNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: 0.4)))
		stoneNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: 30), duration: 60))
//		stoneNode.physicsBody?.applyForce(SCNVector3(randomOffsetForce, randomOffsetForce, randomOffsetForce), asImpulse: true)
		
		
		if let planeNode = scene.rootNode.childNode(withName: "debugPlaneNode", recursively: true) {
			planeNode.addChildNode(stoneNode)
		}
		
	}
	
	private func spawnCoin() {
		guard let planeNode = planeNode else { return }
		let x = Float.random(in: -3...3)
		let y = Float.random(in: -3...3)
		let z = planeNode.position.z - 8
		
		let coinNode = CoinNode.spawnCoin()
		coinNode.position = SCNVector3(x, y, z)
		
		coinNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: 0.4)))
		coinNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: 30), duration: 20))
		
		
		if let planeNode = scene.rootNode.childNode(withName: "debugPlaneNode", recursively: true) {
			planeNode.addChildNode(coinNode)
		}
	}
	
	private func removeNodeWithExplosion(_ node: SCNNode) {
		let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
		let systemNode = SCNNode()
		systemNode.addParticleSystem(particleSystem!)
		systemNode.position = node.position
		sceneView.scene.rootNode.addChildNode(systemNode)
//		nodeA.addChildNode(systemNode)
		
		node.removeFromParentNode()
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

