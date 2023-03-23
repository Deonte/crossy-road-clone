//
//  MainLevelViewController.swift
//  Crossy
//
//  Created by Deonte Kilgore on 3/3/23.
//

import UIKit
import QuartzCore
import SceneKit

enum GameState {
    case menu, playing, gameOver
}

class MainLevelViewController: UIViewController {
    
    var scene: SCNScene!
    var sceneView: SCNView!
    var gameHUD: GameHUD!
    var gameState = GameState.menu
    var score = 0
    
    var cameraNode = SCNNode()
    var lightNode = SCNNode()
    var playerNode = SCNNode()
    var collisionNode = CollisionNode()
    var mapNode = SCNNode()
    var laneNodes = [LaneNode]()
    var laneCount = 0
    
    var jumpForwardAction: SCNAction?
    var jumpLeftAction: SCNAction?
    var jumpRightAction: SCNAction?
    var jumpBackwardAction: SCNAction?
    var driveRightAction: SCNAction?
    var driveLeftAction: SCNAction?
    var dieAction: SCNAction?

    var frontBlocked = false
    var rightBlocked = false
    var leftBlocked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .menu:
            setupGestures()
            gameHUD = GameHUD(with: sceneView.bounds.size, menu: false)
            sceneView.overlaySKScene = gameHUD
            sceneView.overlaySKScene?.isUserInteractionEnabled = false
            gameState = .playing
        default:
            break
        }
    }
    
    private func initializeGame() {
        setupScene()
        setupPlayer()
        setupCollisionNode()
        setupGround()
        setupCamera()
        setupLight()
        setupActions()
        setupTraffic()
    }
   
    private func setupScene() {
        // Retrieve the SCNView
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.sceneView = SCNView(frame: self.view.frame)
            self.view.addSubview(self.sceneView)
            self.sceneView.delegate = self
            self.sceneView.present(self.scene, with: .fade(withDuration: 1), incomingPointOfView: nil)
        }
        
        // Initialize the scene
        scene = SCNScene()
        scene.physicsWorld.contactDelegate = self
        // Attach the scene to the view
        scene.rootNode.addChildNode(mapNode)
        
        DispatchQueue.main.async {
            self.gameHUD = GameHUD(with: self.sceneView.bounds.size, menu: true)
            self.sceneView.overlaySKScene = self.gameHUD
            self.sceneView.overlaySKScene?.isUserInteractionEnabled = false
            self.sceneView.scene = self.scene
        }
        
        for _ in 0..<10 {
            createNewLane(initial: true)
        }
        
        for _ in 0..<25 {
           createNewLane(initial: false)
        }
    }
    
    private func setupPlayer() {
        guard let playerScene = SCNScene(named: Constants.Scenes.chicken) else { return }
        
        if let player = playerScene.rootNode.childNode(withName: "player", recursively: true) {
            playerNode = player
            playerNode.position = SCNVector3(x: 0, y: 0, z: 0)
            scene.rootNode.addChildNode(playerNode)
        }
    }
    
    private func setupGround() {
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIImage(named: Constants.Textures.grassOne)
        floor.firstMaterial?.diffuse.wrapS = .repeat
        floor.firstMaterial?.diffuse.wrapT = .repeat
        floor.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(12.5, 12.5, 12.5)
        floor.reflectivity = 0.001
        
        let floorNode = SCNNode(geometry: floor)
        scene.rootNode.addChildNode(floorNode)
    }
    
    private func setupCamera() {
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 0)
        cameraNode.eulerAngles = SCNVector3(x: -toRadians(angle: 60), y: toRadians(angle: 20), z: 0)
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupLight() {
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        
        let directionalNode = SCNNode()
        directionalNode.light = SCNLight()
        directionalNode.light?.type = .directional
        directionalNode.light?.castsShadow = true
        directionalNode.light?.shadowColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        directionalNode.position = SCNVector3(x: -5, y: 50, z: 0)
        directionalNode.eulerAngles = SCNVector3(x: 0, y: -toRadians(angle: 90), z: -toRadians(angle: 60))
        
        lightNode.addChildNode(ambientNode)
        lightNode.addChildNode(directionalNode)
        lightNode.position = cameraNode.position
        
        scene.rootNode.addChildNode(lightNode)
    }
    
    private func setupGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeUp.direction = .up
        sceneView.addGestureRecognizer(swipeUp)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeft.direction = .left
        sceneView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .right
        sceneView.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRight.direction = .down
        sceneView.addGestureRecognizer(swipeDown)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
    }
    
    private func setupTraffic() {
        for lane in laneNodes {
            if let trafficNode = lane.trafficNode {
                addActions(for: trafficNode)
            }
        }
    }
    
    private func setupActions() {
        // Jump Animation
        let moveUpAction = SCNAction.moveBy(x: 0, y: 1.0, z: 0, duration: 0.1)
        let moveDownAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration: 0.1)
        moveUpAction.timingMode = .easeOut
        moveDownAction.timingMode = .easeIn
        let jumpAction = SCNAction.sequence([moveUpAction, moveDownAction])
        
        // Move character in certain direction
        let moveForwardAction = SCNAction.moveBy(x: 0, y: 0, z: -1, duration: 0.2)
        let moveLeftAction = SCNAction.moveBy(x: -1.0, y: 0, z: 0, duration: 0.2)
        let moveRightAction = SCNAction.moveBy(x: 1.0, y: 0, z: 0, duration: 0.2)
        let moveBackwardAction = SCNAction.moveBy(x: 0, y: 0, z: 1, duration: 0.2)
        
        // Rotate character in a particular direction.
        let turnForwardAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 180), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnLeftAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: -90), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnRightAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 90), z: 0, duration: 0.2, usesShortestUnitArc: true)
        let turnBackwardAction = SCNAction.rotateTo(x: 0, y: toRadians(angle: 360), z: 0, duration: 0.2, usesShortestUnitArc: true)
        
        jumpForwardAction = SCNAction.group([turnForwardAction, jumpAction, moveForwardAction])
        jumpRightAction = SCNAction.group([turnRightAction, jumpAction, moveRightAction])
        jumpLeftAction = SCNAction.group([turnLeftAction, jumpAction, moveLeftAction])
        jumpBackwardAction = SCNAction.group([turnBackwardAction, jumpAction, moveBackwardAction])
        
        driveRightAction = SCNAction.repeatForever(SCNAction.moveBy(x: 2.0, y: 0, z: 0, duration: 1))
        driveLeftAction = SCNAction.repeatForever(SCNAction.moveBy(x: -2.0, y: 0, z: 0, duration: 1))
        
        dieAction = SCNAction.moveBy(x: 0, y: 5, z: 0, duration: 1)
    }
    
    private func setupCollisionNode() {
        collisionNode = CollisionNode()
        collisionNode.position = playerNode.position
        scene.rootNode.addChildNode(collisionNode)
    }
    
    private func jumpForward() {
        if let action = jumpForwardAction {
            addNewLanes()
            playerNode.runAction(action) {
                self.checkBlocks()
                self.score += 1
                self.gameHUD.pointsLabel?.text = "\(self.score)"
            }
        }
    }
    
    private func updatePositions() {
        collisionNode.position = playerNode.position
        /// Update the positions of the camera on the x and z axis.
        let diffX = (playerNode.position.x + 1 - cameraNode.position.x)
        let diffZ = (playerNode.position.z + 2 - cameraNode.position.z)
        
        cameraNode.position.x += diffX
        cameraNode.position.z += diffZ
        
        lightNode.position = cameraNode.position
    }
    
    private func addNewLanes() {
        for _ in 0...3 {
            createNewLane(initial: false)
        }
        
        removeUnusedLanes()
    }
    
    private func removeUnusedLanes() {
        for child in mapNode.childNodes {
            // Checks if the node in the view and is behind the player to delete unused nodes.
            if !sceneView.isNode(child, insideFrustumOf: cameraNode) && child.worldPosition.z > playerNode.worldPosition.z {
                child.removeFromParentNode()
                laneNodes.removeFirst()
                print("removed unused lane.")
            }
        }
    }
    
    func updateTraffic() {
        for lane in laneNodes {
            guard let trafficNode = lane.trafficNode else {
                continue
            }
            
            for vehicle in trafficNode.childNodes {
                if vehicle.position.x > 14 {
                    vehicle.position.x = -14
                } else if vehicle.position.x < -14 {
                    vehicle.position.x = 14
                }
            }
        }
    }
    
    private func createNewLane(initial: Bool) {
        let laneType = randomBool(odds: 3) || initial  ?  LaneType.grass : .road
        let lane = LaneNode(type: laneType, width: 28)
        lane.position = SCNVector3(x: 0, y: 0, z: 5 - Float(laneCount))
        
        laneCount += 1
        laneNodes.append(lane)
        
        mapNode.addChildNode(lane)
        
        if let trafficNode = lane.trafficNode {
            addActions(for: trafficNode)
        }
    }
    
    func addActions(for trafficNode: TrafficNode) {
        guard let driveAction = trafficNode.directionRight ? driveRightAction : driveLeftAction else {
            return
        }
        
        /// Vehicles drive at different speeds.
        
        driveAction.speed = 1 / CGFloat(trafficNode.vehicleType + 1) + 0.5
        
        for vehicle in trafficNode.childNodes {
            vehicle.removeAllActions()
            vehicle.runAction(driveAction)
        }
    }
    
    private func gameOver() {
        DispatchQueue.main.async {
            if let gestureRecognizers = self.sceneView.gestureRecognizers {
                for recognizer in gestureRecognizers {
                    self.sceneView.removeGestureRecognizer(recognizer)
                }
            }
        }
        
        gameState = .gameOver
        if let action = dieAction {
            playerNode.runAction(action) {
                self.resetGame()
            }
        }
    }
    
    private func resetGame() {
        scene.rootNode.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
        scene = nil
        gameState = .menu
        score = 0
        laneCount = 0
        laneNodes = []
        initializeGame()
    }
}

extension MainLevelViewController: SCNSceneRendererDelegate {
    /// Updates constantly
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        updatePositions()
        updateTraffic()
    }
}

extension MainLevelViewController {
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:
            if !frontBlocked {
                checkBlocks()
                jumpForward()
            }
        case .down:
            if let action = jumpBackwardAction {
                playerNode.runAction(action) {
                    self.checkBlocks()
                }
            }
        case .right:
            if playerNode.position.x < 5 && !rightBlocked {
                if let action = jumpRightAction {
                    playerNode.runAction(action) {
                        self.checkBlocks()
                    }
                }
            }
        case .left:
            if playerNode.position.x > -5 && !leftBlocked {
                if let action = jumpLeftAction {
                    playerNode.runAction(action) {
                        self.checkBlocks()
                    }
                }
            }
        default:
            break
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if !frontBlocked {
            checkBlocks()
            jumpForward()
        }
    }
    
    func checkBlocks() {
        if scene.physicsWorld.contactTest(with: collisionNode.front.physicsBody!, options: nil).isEmpty {
            frontBlocked = false
        }
        
        if scene.physicsWorld.contactTest(with: collisionNode.left.physicsBody!, options: nil).isEmpty {
            leftBlocked = false
        }
        
        if scene.physicsWorld.contactTest(with: collisionNode.right.physicsBody!, options: nil).isEmpty {
            rightBlocked = false
        }
    }
}

extension MainLevelViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard let categoryA = contact.nodeA.physicsBody?.categoryBitMask,
              let categoryB = contact.nodeB.physicsBody?.categoryBitMask else {
            return
        }
        
        let mask = categoryA | categoryB
        
        switch mask {
        case PhysicsCategory.chicken | PhysicsCategory.vehicle:
            gameOver()
        case PhysicsCategory.vegetation | PhysicsCategory.collisionTestFront:
            frontBlocked = true
        case PhysicsCategory.vegetation | PhysicsCategory.collisionTestLeft:
            leftBlocked = true
        case PhysicsCategory.vegetation | PhysicsCategory.collisionTestRight:
            rightBlocked = true
        default:
            break
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
    }
}
