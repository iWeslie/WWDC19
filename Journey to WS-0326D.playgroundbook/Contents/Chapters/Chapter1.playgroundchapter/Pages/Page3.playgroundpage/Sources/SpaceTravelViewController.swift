//
//  SpaceTravelViewController.swift
//  MindTheStone3D
//
//  Created by Weslie on 2019/3/22.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PlaygroundSupport

public class SpaceTravelViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    
    var sceneView = ARSCNView()
    var scene: SCNScene!
    var spawnPlane: SCNNode!
    var shipNode: SCNNode!
    
    var playBtn: UIButton?
    var hudImg: UIImageView?
    
    var scoreBtn: UIButton?
    var lifeBtn: UIButton?
    lazy var dispatchOnce : Void  = {
        playSound(.win)

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            PlaygroundPage.current.assessmentStatus = .pass(message: "You made it! Congratulations🎉You may continue to play the game to achieve higher score.")
        }

        return
    }()
    
    var score = 0 {
        didSet {
            if score >= 200 {
                _ = dispatchOnce
            }
        }
    }
    var life = 3
    
    private var allNodes = Set<SCNNode>()
    
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
    
    private lazy var diamondGenerator: Timer = {
        return Timer(timeInterval: 15.0, repeats: true) {_ in
            self.spawnDiamond()
        }
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupNode()
        setupHUD()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let (direction, currentVector) = fetchUserLocation(in: self.sceneView.session.currentFrame)
        let geometryNode = LazerNode.fireLazer(acc: direction)
        geometryNode.position = currentVector
        geometryNode.physicsBody?.applyForce(direction * 20, asImpulse: true)
        scene.rootNode.addChildNode(geometryNode)

        playSound(.bullet)
    }
    
    func setupScene() {
        self.view = sceneView
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        scene = sceneView.scene

        sceneView.clipsToBounds = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor),
            sceneView.topAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor)
            ])
        
        let configuration = ARWorldTrackingConfiguration()
//        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [])

    }
    
    func setupNode() {
        let plane = SCNPlane(width: 6, height: 10)
        let planeNode = SCNNode(geometry: plane)
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "portal.png")
        
        spawnPlane = planeNode
        scene.rootNode.addChildNode(planeNode)
        spawnPlane.position.z -= 8
        
        let shipGeometry = SCNBox(width: 1, height: 1, length: 0.01, chamferRadius: 0.2)
        shipGeometry.firstMaterial?.diffuse.contents = UIColor.clear
        
        let shipNode = SCNNode(geometry: shipGeometry)
        let shape = SCNPhysicsShape(geometry: shipGeometry, options: nil)
        shipNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        shipNode.physicsBody?.isAffectedByGravity = false
        shipNode.physicsBody?.categoryBitMask = CollisionCategory.ship.rawValue
        shipNode.physicsBody?.contactTestBitMask = CollisionCategory.stone.rawValue
        scene.rootNode.addChildNode(shipNode)
        self.shipNode = shipNode
    }
    
    func setupTimer() {
        DispatchQueue.main.async {
            RunLoop.main.add(self.stoneGenerator, forMode: RunLoop.Mode.common)
            RunLoop.main.add(self.coinGenerator, forMode: RunLoop.Mode.common)
            RunLoop.main.add(self.diamondGenerator, forMode: RunLoop.Mode.common)
        }
    }
    
    func setupHUD() {
        let screenFrame = UIScreen.main.bounds
        let centerPosition = CGPoint(x: screenFrame.width / 2 - 30, y: screenFrame.height / 2  - 20)
        let hudImg = UIImageView(frame: CGRect(origin: centerPosition, size: CGSize(width: 60, height: 40)))
        hudImg.image = UIImage(named: "hud_small")
        hudImg.contentMode = .scaleAspectFit
        self.view.addSubview(hudImg)
        
        let spaceshipImg = UIImageView(image: UIImage(named: "spaceship"))
        spaceshipImg.frame = UIScreen.main.bounds
        spaceshipImg.contentMode = .scaleAspectFill
        self.view.addSubview(spaceshipImg)
        
        let leftHUD = UIImageView(frame: CGRect(x: 20, y: 60, width: 200, height: 325))
        leftHUD.image = UIImage(named: "left_hud")
        leftHUD.contentMode = .scaleAspectFill
        self.view.addSubview(leftHUD)
        
        playBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 300, y: 160, width: 600, height: 80))
        playBtn?.setTitle("Tap to enter space", for: .normal)
        playBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .thin)
        playBtn?.titleLabel?.textColor = UIColor.white
        playBtn?.addTarget(self, action: #selector(playBtnClicked), for: .touchUpInside)
        self.view.addSubview(playBtn!)
        
        let lifeBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 200, y: 40, width: 200, height: 80))
        lifeBtn.setTitle("❤️ \(life)", for: .normal)
        lifeBtn.isUserInteractionEnabled = false
        lifeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .light)
        lifeBtn.titleLabel?.textColor = UIColor.white
        self.lifeBtn = lifeBtn
        self.view.addSubview(lifeBtn)
        
        let scoreBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 200, y: 120, width: 200, height: 80))
        scoreBtn.setTitle("🎯 0", for: .normal)
        scoreBtn.isUserInteractionEnabled = false
        scoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .light)
        scoreBtn.titleLabel?.textColor = UIColor.white
        self.scoreBtn = scoreBtn
        self.view.addSubview(scoreBtn)
    }
    
    @objc func playBtnClicked() {
        setupTimer()
        
        playBackgroundMusic()
        
        spawnPlane.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
        
        let skySphere = SCNSphere(radius: 20)
        skySphere.firstMaterial?.diffuse.contents = UIImage(named: "sky2.png")
        // skySphere.firstMaterial?.diffuse.contents = UIColor.black
        skySphere.firstMaterial?.isDoubleSided = true
        let skyNode = SCNNode(geometry: skySphere)
        sceneView.scene.rootNode.addChildNode(skyNode)

        playBtn?.removeFromSuperview()
    }
}

// MARK: - SCNSceneRendererDelegate
extension SpaceTravelViewController: SCNSceneRendererDelegate, ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        for node in allNodes {
            if node.presentation.position.z > 10 {
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
                self.allNodes.remove(node)
            }
        }
        
        let cameraPosition = fetchUserLocation(in: self.sceneView.session.currentFrame).position
        shipNode.position = cameraPosition
    }
    
}

// MARK: - SCNPhysicsContactDelegate
extension SpaceTravelViewController: SCNPhysicsContactDelegate {
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.lazer.rawValue {
            let lazerNode = contact.nodeB
            lazerNode.removeFromParentNode()
            
            let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
            let systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem!)
            
            contact.nodeA.addChildNode(systemNode)
            contact.nodeA.physicsBody = SCNPhysicsBody()
            contact.nodeA.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
           
            if contact.nodeA.name == "stone" {
                score += 1
                playSound(.hitStone)
            } else if contact.nodeA.name == "coin" {
                score += 10
                playSound(.hitCoin)
            } else if contact.nodeA.name == "diamond" {
                score += 50
                playSound(.hitDiamond)
            }
            
            DispatchQueue.main.async {
                self.scoreBtn?.setTitle("🎯 \(self.score)", for: .normal)
            }
        }
        
        if contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.stone.rawValue {
            if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.ship.rawValue {
                print("hit ship")
                
                contact.nodeB.removeFromParentNode()
                DispatchQueue.main.async {
                    self.stoneHitShip()
                }
                
                life -= 1
                playSound(.hitShip)
                DispatchQueue.main.async {
                    self.lifeBtn?.setTitle("❤️ \(self.life)", for: .normal)
                }
                if life <= 0 {
                    print("You lose")
                    playSound(.lose)
                    DispatchQueue.main.async {
                        self.gameOver()
                    }
                }
            }
        }
    }
}

extension SpaceTravelViewController {
    private func spawnStone() {
        let x = Float.random(in: -3...3)
        let y = Float.random(in: -3...3)
        let z = spawnPlane.position.z
        
        let stoneNode = StoneNode.spawnStone()
        stoneNode.position = SCNVector3(x, y, z)
        self.allNodes.insert(stoneNode)
        
//        let randomOffsetForce = CGFloat.random(in: -0.01...0.01)
        stoneNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: TimeInterval.random(in: 0.1...1))))
        
        stoneNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: 20), duration: TimeInterval.random(in: 5...50)))
        stoneNode.runAction(SCNAction.sequence([
            SCNAction.move(by: SCNVector3(x: 0, y: 0, z: 20), duration: 30),
            ]))
        //        stoneNode.physicsBody?.applyForce(SCNVector3(randomOffsetForce, randomOffsetForce, randomOffsetForce), asImpulse: true)
        
        spawnPlane.addChildNode(stoneNode)
    }
    
    private func spawnCoin() {
        let x = Float.random(in: -3...3)
        let y = Float.random(in: -3...3)
        let z = spawnPlane.position.z
        
        let coinNode = CoinNode.spawnCoin()
        self.allNodes.insert(coinNode)

        coinNode.position = SCNVector3(x, y, z)
        coinNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: 0.4)))
        coinNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: 30), duration: TimeInterval.random(in: 10...20)))
        
        spawnPlane.addChildNode(coinNode)
    }
    
    private func spawnDiamond() {
        let x = Float.random(in: -3...3)
        let y = Float.random(in: -3...3)
        let z = spawnPlane.position.z
        
        let coinNode = CoinNode.spawnDiamond()
        self.allNodes.insert(coinNode)

        coinNode.position = SCNVector3(x, y, z)
        coinNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 1, y: 0, z: 0, duration: 0.4)))
        coinNode.runAction(SCNAction.move(by: SCNVector3(x: 0, y: 0, z: 30), duration: 10))
        
        spawnPlane.addChildNode(coinNode)
    }

    private func playBackgroundMusic() {
        let music = SCNAudioSource(fileNamed: "background.mp3")!
        music.volume = 0.3
        let musicPlayer = SCNAudioPlayer(source: music)
        music.loops = true
        music.shouldStream = true
        music.isPositional = false
        scene.rootNode.addAudioPlayer(musicPlayer)
    }
    
    private func stoneHitShip() {
        let coverView = UIView(frame: UIScreen.main.bounds)
        coverView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        self.view.addSubview(coverView)
        UIView.animate(withDuration: 0.5, animations: {
            coverView.alpha = 0
        }) { (_) in
            coverView.removeFromSuperview()
        }
    }
    
    private func gameOver() {
        let gameOverView = UIView(frame: UIScreen.main.bounds)
        gameOverView.backgroundColor = UIColor.red.withAlphaComponent(0.6)
        let hud = UIImageView(frame: CGRect(x: UIScreen.main.bounds.width / 2  - 200, y: 100, width: 400, height: 248))
        hud.image = UIImage(named: "game_over.png")
        hud.contentMode = .scaleAspectFill
        gameOverView.addSubview(hud)
        self.view.addSubview(gameOverView)
        self.sceneView.session.pause()
        allNodes.forEach { $0.removeAllActions() }
        
        stoneGenerator.invalidate()
        coinGenerator.invalidate()
        diamondGenerator.invalidate()
        
        self.view.isUserInteractionEnabled = false
    }
}
