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
    
    @Published var isRecording = false
    @Published var recordedData = [MotionData]()
    @Published var storedGestureData = [MotionData]()
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
                self?.recordedData.append(data)
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
    
    func saveDataToFile() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("GestureData.json")

        do {
            let data = try JSONEncoder().encode(recordedData)
            try data.write(to: fileURL)
            isSaveSuccessful = true
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    func loadStoredGestureData(completion: @escaping () -> Void) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("GestureData.json")

        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let data = try Data(contentsOf: fileURL)
                storedGestureData = try JSONDecoder().decode([MotionData].self, from: data)
                completion()
            } else {
                print("Stored gesture data file does not exist")
            }
        } catch {
            print("Error loading stored gesture data: \(error)")
        }
    }
}
