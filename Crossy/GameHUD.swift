//
//  GameHUD.swift
//  Crossy
//
//  Created by Deonte Kilgore on 3/23/23.
//

import SpriteKit

class GameHUD: SKScene {
    var logoLabel: SKLabelNode?
    var tapToPlayLabel: SKLabelNode?
    var pointsLabel: SKLabelNode?
    
    init(with size: CGSize, menu: Bool) {
        super.init(size: size)
        
        if menu {
            addMenuLabels()
        } else {
            addPointsLabel()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addMenuLabels() {
        logoLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
        tapToPlayLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")

        guard let logoLabel = logoLabel, let tapToPlayLabel = tapToPlayLabel else { return }
        
        logoLabel.text = "Crossy Road"
        logoLabel.fontSize = 35
        logoLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(logoLabel)
        
        tapToPlayLabel.text = "Tap to play"
        tapToPlayLabel.fontSize = 25
        tapToPlayLabel.position = CGPoint(x: frame.midX, y: frame.midY - logoLabel.frame.size.height)
        addChild(tapToPlayLabel)
    }
    
    func addPointsLabel() {
        pointsLabel = SKLabelNode(fontNamed: "8BIT WONDER Nominal")
        
        guard let pointsLabel = pointsLabel else { return }
        pointsLabel.text = "0"
        pointsLabel.fontSize = 40
        pointsLabel.position = CGPoint(x: frame.minX + pointsLabel.frame.size.width, y: frame.maxY - pointsLabel.frame.size.height * 2)
        addChild(pointsLabel)
    }
    
    
}

