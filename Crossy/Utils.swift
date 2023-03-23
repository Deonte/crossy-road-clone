//
//  Utils.swift
//  Crossy
//
//  Created by Deonte Kilgore on 3/4/23.
//

import SceneKit

let degreesPerRadians = Float(Double.pi / 180)
let radiansPerDegrees = Float(180/Double.pi)

func toRadians(angle: Float) -> Float {
    return angle * degreesPerRadians
}

func toRadians(angle: CGFloat) -> CGFloat {
    return angle * CGFloat(degreesPerRadians)
}

func randomBool(odds: Int) -> Bool {
    let random = arc4random_uniform(UInt32(odds))
    
    if random < 1 {
        return true
    } else {
        return false
    }
}
