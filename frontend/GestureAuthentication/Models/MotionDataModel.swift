//
//  MotionDataModel.swift
//  GestureAuthentication
//
//  Created by Jonathan Andika on 21/01/24.
//

import Foundation
import CoreMotion

struct MotionData: Codable {
    var timestamp: TimeInterval
    var acceleration: CodableAcceleration
    var rotationRate: CodableRotationRate

    // Initialize with CMAcceleration and CMRotationRate for convenience
    init(timestamp: TimeInterval, acceleration: CMAcceleration, rotationRate: CMRotationRate) {
        self.timestamp = timestamp
        self.acceleration = CodableAcceleration(x: acceleration.x, y: acceleration.y, z: acceleration.z)
        self.rotationRate = CodableRotationRate(x: rotationRate.x, y: rotationRate.y, z: rotationRate.z)
    }
}

struct CodableAcceleration: Codable {
    var x: Double
    var y: Double
    var z: Double
}

struct CodableRotationRate: Codable {
    var x: Double
    var y: Double
    var z: Double
}

