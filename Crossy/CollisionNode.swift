//
//  CollisionNode.swift
//  Crossy
//
//  Created by Deonte Kilgore on 3/6/23.
//

import SceneKit

class CollisionNode: SCNNode {
    let front: SCNNode
    let left: SCNNode
    let right: SCNNode
    
    override init() {
        front = SCNNode()
        left = SCNNode()
        right = SCNNode()
        
        super.init()
        createPhysicsBodies()
    }
    
    func createPhysicsBodies() {
        let boxGeometry = SCNBox(width: 0.25, height: 0.25, length: 0.25, chamferRadius: 0)
        boxGeometry.firstMaterial?.diffuse.contents = UIColor.clear
        
        let shape = SCNPhysicsShape(geometry: boxGeometry, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.boundingBox])
        
        front.geometry = boxGeometry
        left.geometry = boxGeometry
        right.geometry = boxGeometry
        
        front.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        front.physicsBody?.categoryBitMask = PhysicsCategory.collisionTestFront
        front.physicsBody?.contactTestBitMask = PhysicsCategory.vegetation
        
        left.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        left.physicsBody?.categoryBitMask = PhysicsCategory.collisionTestLeft
        left.physicsBody?.contactTestBitMask = PhysicsCategory.vegetation
        
        right.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        right.physicsBody?.categoryBitMask = PhysicsCategory.collisionTestRight
        right.physicsBody?.contactTestBitMask = PhysicsCategory.vegetation
        
        front.position = .init(0, 0.5, -0.5)
        left.position = .init(-0.5, 0.5, 0)
        right.position = .init(0.5, 0.5, 0)
        
        addChildNode(front)
        addChildNode(left)
        addChildNode(right)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
