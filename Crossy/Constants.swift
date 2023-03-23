//
//  Constants.swift
//  Crossy
//
//  Created by Deonte Kilgore on 3/4/23.
//

import SceneKit

enum Constants {
    
    enum Scenes {
        static let chicken = "art.scnassets/chicken.scn"
    }
    
    enum Textures {
        static let grassOne = "art.scnassets/GrassOne.png"
        static let grassTwo = "art.scnassets/GrassTwo.png"
        static let road = "art.scnassets/Road.png"
    }
    
    struct Models {
        private static let largeTree = SCNScene(named: "art.scnassets/LargeTree.scn")!
        static let largeTreeNode = largeTree.rootNode.childNode(withName: "tree", recursively: true)!

        private static let mediumTree = SCNScene(named: "art.scnassets/MediumTree.scn")!
        static let mediumTreeNode = mediumTree.rootNode.childNode(withName: "tree", recursively: true)!
        
        private static let smallTree = SCNScene(named: "art.scnassets/SmallTree.scn")!
        static let smallTreeNode = smallTree.rootNode.childNode(withName: "tree", recursively: true)!
        
        private static let tallestTree = SCNScene(named: "art.scnassets/TallestTree.scn")!
        static let tallestTreeNode = tallestTree.rootNode.childNode(withName: "tree", recursively: true)!
        
        private static let rock = SCNScene(named: "art.scnassets/Rock.scn")!
        static let rockNode = rock.rootNode.childNode(withName: "rock", recursively: true)!
        
        private static let blueCar = SCNScene(named: "art.scnassets/BlueCar.scn")!
        static let blueCarNode = blueCar.rootNode.childNode(withName: "car", recursively: true)!
        
        private static let greenCar = SCNScene(named: "art.scnassets/GreenCar.scn")!
        static let greenCarNode = greenCar.rootNode.childNode(withName: "car", recursively: true)!
        
        private static let purpleCar = SCNScene(named: "art.scnassets/PurpleCar.scn")!
        static let purpleCarNode = purpleCar.rootNode.childNode(withName: "car", recursively: true)!
        
        private static let taxiCar = SCNScene(named: "art.scnassets/TaxiCar.scn")!
        static let taxiCarNode = taxiCar.rootNode.childNode(withName: "car", recursively: true)!
        
        private static let sportsCar = SCNScene(named: "art.scnassets/SportsCar.scn")!
        static let sportsCarNode = sportsCar.rootNode.childNode(withName: "car", recursively: true)!
        
        private static let blueTruck = SCNScene(named: "art.scnassets/BlueTruck.scn")!
        static let blueTruckNode = blueTruck.rootNode.childNode(withName: "truck", recursively: true)!
        
        private static let redTruck = SCNScene(named: "art.scnassets/RedTruck.scn")!
        static let redTruckNode = redTruck.rootNode.childNode(withName: "truck", recursively: true)!
    }
    
}
