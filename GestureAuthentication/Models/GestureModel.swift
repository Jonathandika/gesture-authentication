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

class GestureModel: ObservableObject {
    private var motionManager = CMMotionManager()
    private var timer: Timer?
    
    @Published var gestureDataName = ""
    @Published var isRecording = false
    @Published var recordedData = [MotionData]()
    @Published var isSaveSuccessful: Bool = false

    private func startRecording() {
        print("Start Recording...")
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
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                    self?.recordedData.append(data)
                }
               
            }
        }
    }

    func stopRecording() {
        isRecording = false
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        timer?.invalidate()
        timer = nil
        print("Recording Stopped")
        // Process or store the recordedData as needed
    }

    func toggleRecording() {
        print("Toggling Recording")
        isRecording ? stopRecording() : startRecording()
    }

    
    func resetRecording() {
        stopRecording()
        recordedData.removeAll()
    }
    
    func saveDataToFile(gestureData: [MotionData], gestureDataName: String = "GestureData") {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(gestureDataName + ".json")

        do {
            let data = try JSONEncoder().encode(gestureData)
            try data.write(to: fileURL)
            isSaveSuccessful = true
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    func toJsonData(recordedData: [MotionData]) -> Data? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(recordedData)
            return jsonData
        } catch {
            print("Error encoding GestureModel to JSON: \(error)")
            return nil
        }
    }
    
    
}
