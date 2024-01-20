//
//  GestureCreationModel.swift
//  GestureAuthentication
//
//  Created by Jonathan Andika on 20/01/24.
//

import Foundation
import CoreMotion
import Combine
import SwiftUI

class GestureCreationModel: ObservableObject {
    private var motionManager = CMMotionManager()
    private var timer: Timer?
    
    @Published var isRecording = false
    @Published var recordedData = [MotionData]()

    struct MotionData {
        var timestamp: TimeInterval
        var acceleration: CMAcceleration
        var rotationRate: CMRotationRate

        // Computed properties for acceleration components
        var x: Double { acceleration.x }
        var y: Double { acceleration.y }
        var z: Double { acceleration.z }
    }

    func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    private func startRecording() {
        recordedData.removeAll()
        isRecording = true
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            if let accelerometerData = self?.motionManager.accelerometerData,
               let gyroData = self?.motionManager.gyroData {
                let data = MotionData(timestamp: accelerometerData.timestamp,
                                      acceleration: accelerometerData.acceleration,
                                      rotationRate: gyroData.rotationRate)
                self?.recordedData.append(data)
            }
        }
    }

    private func stopRecording() {
        isRecording = false
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        timer?.invalidate()
        timer = nil

        // Process or store the recordedData as needed
    }
    
}
