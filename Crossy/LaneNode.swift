//
//  LaneNode.swift
//  Crossy
//
//  Created by Deonte Kilgore on 3/4/23.
//

import SceneKit

enum LaneType {
    case grass, road
}

class TrafficNode: SCNNode {
    let vehicleType: Int
    let directionRight: Bool
    
    init(type: Int, directionRight: Bool) {
        self.vehicleType = type
        self.directionRight = directionRight
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LaneNode: SCNNode {
    let type: LaneType
    var trafficNode: TrafficNode?
    
    init(type: LaneType, width: CGFloat) {
        self.type = type
        super.init()
        
        switch type {
        case .grass:
            guard let texture = randomBool(odds: 3) ? UIImage(named: Constants.Textures.grassOne) : UIImage(named: Constants.Textures.grassTwo) else { break }
            createLane(width: width, height: 0.4, image: texture)
        case .road:
            guard let texture = UIImage(named: Constants.Textures.road) else { break }
            trafficNode = TrafficNode(type: Int(arc4random_uniform(UInt32(7))), directionRight: randomBool(odds: 2))
            addChildNode(trafficNode!)
            createLane(width: width, height: 0.05, image: texture)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLane(width: CGFloat, height: CGFloat, image: UIImage) {
        let laneGeometry = SCNBox(width: width, height: height, length: 1, chamferRadius: 0)
        laneGeometry.firstMaterial?.diffuse.contents = image
        laneGeometry.firstMaterial?.diffuse.wrapT = .repeat
        laneGeometry.firstMaterial?.diffuse.wrapS = .repeat
        laneGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), 1, 1)
        
        let laneNode = SCNNode(geometry: laneGeometry)
        addChildNode(laneNode)
        addElements(width, laneNode)
    }
    
    func addElements(_ width: CGFloat, _ laneNode: SCNNode) {
        var carGap = 0
        
        for index in 0 ..< Int(width) {
            if type == .grass {
                if randomBool(odds: 7) {
                    let vegetation = getVegetation()
                    // Starts at very right edge of lane and for each new iteration move one tile to the left.
                    vegetation.position = SCNVector3(x: 10 - Float(index), y: 0, z: 0)
                    laneNode.addChildNode(vegetation)
                }
            } else if type == .road {
                carGap += 1
                if carGap > 3 {
                    guard let trafficNode = trafficNode else {
                        continue
                    }
                    
                    if randomBool(odds: 5) {
                        carGap = 0
                        let vehicle = getVehicle(for: trafficNode.vehicleType)
                        vehicle.position = SCNVector3(10 - Float(index), 0, 0)
                        vehicle.eulerAngles = trafficNode.directionRight ? SCNVector3Zero : SCNVector3(x: 0, y: toRadians(angle: 180), z: 0)
                        
                        trafficNode.addChildNode(vehicle)
                    }
                }
            }
        }
    }
    
    func getVegetation() -> SCNNode {
        let numberOfElements = Int.random(in: 1...5)
        var node: SCNNode = .init()
        
        switch numberOfElements {
        case 1:
            node = Constants.Models.largeTreeNode.clone()
        case 2:
            node = Constants.Models.mediumTreeNode.clone()
        case 3:
            node = Constants.Models.smallTreeNode.clone()
        case 4:
            node = Constants.Models.tallestTreeNode.clone()
        case 5:
            node = Constants.Models.rockNode.clone()
        default:
            break
        }
        
        return node
    }
    
    func getVehicle(for type: Int) -> SCNNode {
        switch type {
        case 0:
            return Constants.Models.sportsCarNode.clone()
        case 1:
            return Constants.Models.greenCarNode.clone()
        case 2:
            return Constants.Models.purpleCarNode.clone()
        case 3:
            return Constants.Models.taxiCarNode.clone()
        case 4:
            return Constants.Models.blueCarNode.clone()
        case 5:
            return Constants.Models.redTruckNode.clone()
        case 6:
            return Constants.Models.blueTruckNode.clone()
        default:
            return Constants.Models.blueCarNode.clone()
        }
    }
    
}
