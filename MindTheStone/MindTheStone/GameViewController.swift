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
	
	var baseNode: SCNNode?
	var planeNode: SCNNode?
	var gameNode:SCNNode?

	var updateCount = 0
	
	var playBtn: UIButton?
	
	var scene: SCNScene!
	var wallNode: SCNNode!
	
	var centerPosition: CGPoint!
	
	private var stones = Set<StoneNode>()
	
	private lazy var generator: Timer = {
		return Timer(timeInterval: 1.0, repeats: true) { [weak self](_) in
			self?.spawnStone()
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
		
//		sceneView.session.delegate = self
		
//        let scene = SCNScene(named: "art.scnassets/Scene/GameScene.scn")!
        scene = sceneView.scene
		
		//显示debug特征点
		sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
		
		setupHUD()
		
		setupTimer()
		
        // allows the user to manipulate the camera
//        sceneView.allowsCameraControl = true
		
        // show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
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
	
	func setupNode() {
//		wallNode = scene.rootNode.childNode(withName: "wall", recursively: false)
	}
	
	func setupTimer() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [unowned self] in
			RunLoop.main.add(self.generator, forMode: RunLoop.Mode.common)
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
		centerPosition = CGPoint(x: screenFrame.width / 2 - 15, y: screenFrame.height / 2  - 15)
		let img = UIImageView(frame: CGRect(origin: centerPosition, size: CGSize(width: 30, height: 30)))
		img.image = UIImage(named: "hud")
		img.contentMode = .scaleAspectFit
		self.view.addSubview(img)
		
		playBtn = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
		playBtn?.setTitle("Play", for: .normal)
		playBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 30)
		playBtn?.titleLabel?.textColor = UIColor.red
		playBtn?.addTarget(self, action: #selector(playBtnClicked), for: .touchUpInside)
		self.view.addSubview(playBtn!)
		
		playBtn?.isHidden = true
		
	}
	
	@objc func playBtnClicked() {
		stopTracking()
		
		spawnStone()
		
		// load game scene
		
//		gameNode?.removeFromParentNode()
//		gameNode = SCNNode()
		
	}
	
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
		
		let (direction, currentVector) = fetchUserLocation(in: self.sceneView.session.currentFrame)
		
//		let geometry = SCNSphere(radius: 0.001)
//		geometry.firstMaterial?.diffuse.contents = UIColor.blue
//
//		let geometryNode = SCNNode(geometry: geometry)
//
//
//		geometryNode.position = currentVector
//
//		let shape = SCNPhysicsShape(geometry: geometry, options: nil)
//		geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
//		geometryNode.physicsBody?.isAffectedByGravity = false
//		geometryNode.physicsBody?.applyForce(direction * 5, asImpulse: true)
//
//		let lazer = SCNParticleSystem(named: "lazer.scnp", inDirectory: nil)!
//		lazer.acceleration = direction * (-1) - SCNVector3(x: 0, y: 0.03, z: 0)
//		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
//			lazer.acceleration = direction * (-1)
//		}
//		geometryNode.addParticleSystem(lazer)

		let geometryNode = LazerNode.fireLazer(acc: direction)
		geometryNode.position = currentVector
		geometryNode.physicsBody?.applyForce(direction * 5, asImpulse: true)
		
//		let lazer = SCNParticleSystem(named: "lazer.scnp", inDirectory: nil)!
//		lazer.acceleration = direction * (-1) - SCNVector3(x: 0, y: 0.03, z: 0)
//		
//		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
//			lazer.acceleration = direction * (-1)
//		}
//		geometryNode.addParticleSystem(lazer)
		
		
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
			
			planeNode = SCNNode(geometry: plane)
			planeNode?.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
			planeNode?.opacity = 0.25
			planeNode?.eulerAngles.x = -.pi / 2
			node.addChildNode(planeNode!)
			
			let base = SCNBox(width: 0.5, height: 0, length: 0.5, chamferRadius: 0)
			base.firstMaterial?.diffuse.contents = UIColor.blue
			baseNode = SCNNode(geometry: base)
			baseNode?.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
			
			node.addChildNode(baseNode!)
		}
	}
	
	func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
		guard let planeAnchor = anchor as?  ARPlaneAnchor,
			let planeNode = node.childNodes.first,
			let plane = planeNode.geometry as? SCNPlane
			else { return }
		
		updateCount += 1
		
		
		if updateCount > 20 {
//			print("prepare to start game")
			
			DispatchQueue.main.async {
				self.playBtn?.isHidden = false
			}
			
			
//			stopTracking()
		}
		
		
		// 平面的中心点可以会变动.
		planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
		
		/*
		平面尺寸可能会变大,或者把几个小平面合并为一个大平面.合并时,`ARSCNView`自动删除同一个平面上的相应节点,然后调用该方法来更新保留的另一个平面的尺寸.(经过测试,合并时,保留第一个检测到的平面和对应节点)
		*/
		plane.width = CGFloat(planeAnchor.extent.x)
		plane.height = CGFloat(planeAnchor.extent.z)
	}
	
	
//	func session(_ session: ARSession, didUpdate frame: ARFrame) {
//		print(frame.camera.transform)
//	}
//
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
	@objc func spawnStone() {
		
		guard let baseNode = baseNode else { return }
		
		
		let x = Float.random(in: -0.1...0.1)
		
//		let y: Float = Float(arc4random() % 0.1)
		let y = baseNode.position.y
		let z = Float.random(in: -0.1...0.1)
		
		let stoneNode = StoneNode.spawnStone()
		stoneNode.position = SCNVector3(x, y, z)
		
		self.stones.insert(stoneNode)
		let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
		physicsBody.isAffectedByGravity = false
		physicsBody.applyForce(SCNVector3(0, 0.05, 0), asImpulse: true)
		physicsBody.mass = 0.1
		
		
		stoneNode.physicsBody = physicsBody
		
		scene.rootNode.addChildNode(stoneNode)
	}
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		// ...
	}
}

extension GameViewController: SCNPhysicsContactDelegate {
	func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
		
		if contact.nodeA.categoryBitMask == CollisionCategory.lazer.rawValue {
			print("hit stone")
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

}

