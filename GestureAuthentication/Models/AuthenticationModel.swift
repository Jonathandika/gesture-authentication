//
//  AuthenticationModel.swift
//  GestureAuthentication
//
//  Created by Jonathan Andika on 21/01/24.
//

import Foundation

class AuthenticationModel: ObservableObject {
    @Published var gestureModel = GestureModel()
    @Published var authenticationResult: Bool?
    @Published var comparisonTime: TimeInterval?
    @Published var selectedAlgorithm: GestureComparisonAlgorithm = .defaultAlgorithm
    
    @Published var storedGestureData = [[MotionData]]()
    
    
    init() {
        self.loadStoredGestureData()
    }
    
    
    func loadStoredGestureData() {
        
        for i in (1...3) {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("gestureData_\(i).json")

            do {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    let data = try Data(contentsOf: fileURL)
                    storedGestureData.append(try JSONDecoder().decode([MotionData].self, from: data))
                } else {
                    print("Stored gesture data file does not exist")
                }
            } catch {
                print("Error loading stored gesture data: \(error)")
            }
        }
    }

    enum GestureComparisonAlgorithm {
        case defaultAlgorithm
        case DTW
        case FastDTW
        case Protractor3D
        case GlobalSequenceAlignment
        // Add other algorithms as needed
    }

    func compareGestures(newGesture: [MotionData]) {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd_MM_YY+HH_mm_ss"
        
        gestureModel.saveDataToFile(gestureData: newGesture, gestureDataName: "newGesture_" + dateFormatter.string(from: date))
        let startTime = Date()
        
        // self.authenticationResult = performComparison(recordedData, storedGestureData, using: selectedAlgorithm)
        self.authenticationResult = true
        
        let endTime = Date()
        comparisonTime = endTime.timeIntervalSince(startTime)
    }
    
}

