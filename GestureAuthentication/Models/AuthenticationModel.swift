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
    @Published var distanceScore: Double?
    @Published var comparisonTime: TimeInterval?
    @Published var selectedAlgorithm: GestureComparisonAlgorithm = .DTW
    
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

    enum GestureComparisonAlgorithm: String {
        case DTW = "dtw"
        case FastDTW = "fastdtw"
        case CTW = "ctw"
        case SoftDTW = "softdtw"
        case Euclidean = "euclidean"
        case Correlation = "correlation"
    }

    func compareGestures(newGesture: [MotionData]) {

        guard let jsonData = gestureModel.toJsonData(recordedData: newGesture) else { return }

        guard let url = URL(string: "https://gesture-jetstream.koyeb.app/authenticate-gesture/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let filename = "gesture.json"
        body.append(convertFileData(fieldName: "file",
                                    fileName: filename,
                                    mimeType: "application/json",
                                    fileData: jsonData,
                                    using: boundary))

        body.append(convertFormField(named: "algorithm", value: selectedAlgorithm.rawValue, using: boundary))
        body.append(convertFormField(named: "threshold", value: String(0.15), using: boundary)) // Adjust the threshold as necessary

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(AuthenticationResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.authenticationResult = result.authenticated
                        self.distanceScore = result.distance
                        self.comparisonTime = result.time_taken
                    }
                } catch {
                    print("JSON Decoding Error: \(error)")
                }
            }
        }.resume()
    }
    
    private struct AuthenticationResponse: Decodable {
            var authenticated: Bool
            var distance: Double
            var time_taken: Double
        }

    // These functions remain the same as in your previous model
    private func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
        return data
    }

    private func convertFormField(named name: String, value: String, using boundary: String) -> Data {
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n".data(using: .utf8)!)
        data.append("\r\n".data(using: .utf8)!)
        data.append("\(value)\r\n".data(using: .utf8)!)

        return data
    }

    
}

