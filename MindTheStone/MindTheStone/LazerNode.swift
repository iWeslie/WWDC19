//
//  LazerNode.swift
//  MindTheStone
//
//  Created by Weslie on 2019/3/19.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit

public class LazerNode: SCNNode {
	public override init() {
		super.init()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public static func fireLazer(acc: SCNVector3) -> LazerNode {
		let lazerNode = LazerNode()
		
		let sphere = SCNSphere(radius: 0.005)
		sphere.firstMaterial?.diffuse.contents = UIColor.blue
		
		lazerNode.geometry = sphere
		
		let lazer = SCNParticleSystem(named: "lazer.scnp", inDirectory: nil)!
		lazer.acceleration = acc * (-1) - SCNVector3(x: 0, y: 0.03, z: 0)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
			lazer.acceleration = acc * (-1)
		}
		lazerNode.addParticleSystem(lazer)
		
		let shape = SCNPhysicsShape(geometry: SCNSphere(radius: 0.01), options: nil)
		lazerNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
		lazerNode.physicsBody?.isAffectedByGravity = false
		
		lazerNode.physicsBody?.categoryBitMask = CollisionCategory.lazer.rawValue
		lazerNode.physicsBody?.contactTestBitMask = CollisionCategory.stone.rawValue | CollisionCategory.coin.rawValue
		
		return lazerNode
	}
}

