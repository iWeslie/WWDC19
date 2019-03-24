//
//  Extension+SCNVector3.swift
//  MindTheStone
//
//  Created by Weslie on 2019/3/19.
//  Copyright © 2019 weslie. All rights reserved.
//

import UIKit
import SceneKit

func square(_ x: Float) -> Float {
	return x * x
}

public extension SCNVector3 {

	var length: Float {
		get {
			return Float(sqrt(square(x) + square(y) + square(z)))
		}
	}
	
	func distance(from anotherVector: SCNVector3) -> Float {
		return (square((x - anotherVector.x)) + square((y - anotherVector.y)) + square((z - anotherVector.z)))
	}
	
	static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
		return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
	}
	
	static func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
		return SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
	}
	
	static func *(lhs: SCNVector3, rhs: Float) -> SCNVector3 {
		return SCNVector3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
	}
	
	static func *(lhs: SCNVector3, rhs: SCNVector3) -> Float {
		return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
	}
	
	static func lineEulerAngles(vector: SCNVector3) -> SCNVector3 {
		let height = vector.length
		let xzLength = sqrt(vector.x * vector.x + vector.z * vector.z)
		let pitchB = vector.y < 0 ? Float.pi - asinf(xzLength / height) : asinf(xzLength / height)
		let pitch = vector.z == 0 ? pitchB : sign(vector.z) * pitchB
		
		var yaw: Float = 0
		if vector.x != 0 || vector.z != 0 {
			let inner = vector.x / (height * sinf(pitch))
			if inner > 1 || inner < -1 {
				yaw = Float.pi / 2
			} else {
				yaw = asinf(inner)
			}
		}
		return SCNVector3(CGFloat(pitch), CGFloat(yaw), 0)
	}
	
}
