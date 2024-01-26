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

    var storedGestureData: [MotionData] = []
    
    
    init() {
        gestureModel.loadStoredGestureData() {
            self.storedGestureData = self.gestureModel.storedGestureData
        }
    }

    enum GestureComparisonAlgorithm {
        case defaultAlgorithm
        case DTW
        case Protractor3D
        case FastDTW
        case PrunedDTW
        case GlobalSequenceAlignment
        // Add other algorithms as needed
    }

    func compareGestures(newGesture: [MotionData]) {
        let startTime = Date()
        
        // self.authenticationResult = performComparison(recordedData, storedGestureData, using: selectedAlgorithm)
        self.authenticationResult = true
        
        let endTime = Date()
        comparisonTime = endTime.timeIntervalSince(startTime)
    }

    
}

