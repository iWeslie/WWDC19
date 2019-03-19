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
		let node = LazerNode()
		
		let geometry = SCNSphere(radius: 0.001)
		geometry.firstMaterial?.diffuse.contents = UIColor.blue
		
		node.geometry = geometry
		
		let shape = SCNPhysicsShape(geometry: SCNSphere(radius: 0.01), options: nil)
		node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
		node.physicsBody?.isAffectedByGravity = false
		
		let lazer = SCNParticleSystem(named: "lazer.scnp", inDirectory: nil)!
		lazer.acceleration = acc * (-1) - SCNVector3(x: 0, y: 0.03, z: 0)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
			lazer.acceleration = acc * (-1)
		}
		node.addParticleSystem(lazer)
		
		node.physicsBody?.categoryBitMask = CollisionCategory.lazer.rawValue
		node.physicsBody?.contactTestBitMask = CollisionCategory.stone.rawValue | CollisionCategory.coin.rawValue
		
		//		let material = SCNMaterial()
		//		let n = arc4random() % 10
		//		if n <= 1 {
		//			targetNode.type = TargetNodeType(typeNum: .high)
		//			material.diffuse.contents = UIImage(named: "target-high")
		//		} else if n >= 8 {
		//			targetNode.type = TargetNodeType(typeNum: .demon)
		//			material.diffuse.contents = UIImage(named: "target-demon")
		//		} else {
		//			targetNode.type = TargetNodeType(typeNum: .normal)
		//			material.diffuse.contents = UIImage(named: "target-normal")
		//		}
		//		let whiteMaterial = SCNMaterial()
		//		whiteMaterial.diffuse.contents = targetNode.typeColor
		//		targetNode.geometry?.materials = [whiteMaterial, material, material]
		
		return node
	}
}

