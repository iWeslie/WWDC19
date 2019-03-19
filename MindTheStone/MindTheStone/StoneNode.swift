//
//  StoneNode.swift
//  MindTheStone
//
//  Created by Weslie on 2019/3/18.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit

public class StoneNode: SCNNode {
	public override init() {
		super.init()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public static func spawnStone() -> StoneNode {
		let stoneNode = StoneNode()
		
		let sphere = SCNSphere(radius: 0.2)
//        sphere.firstMaterial?.diffuse.contents = UIImage(named: "stone_1.jpg")
        sphere.firstMaterial?.diffuse.contents = UIColor.red
		stoneNode.geometry = sphere
		
		stoneNode.physicsBody = SCNPhysicsBody()
		stoneNode.physicsBody?.isAffectedByGravity = false
		let shape = SCNPhysicsShape(geometry: sphere, options: nil)
		stoneNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
		
		stoneNode.physicsBody?.categoryBitMask = CollisionCategory.stone.rawValue
		stoneNode.physicsBody?.contactTestBitMask = CollisionCategory.lazer.rawValue | CollisionCategory.ship.rawValue
		
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
		
		return stoneNode
	}
}
