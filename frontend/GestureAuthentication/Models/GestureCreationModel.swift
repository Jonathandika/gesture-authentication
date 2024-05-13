//
//  GestureCreationModel.swift
//  GestureAuthentication
//
//  Created by Jonathan Andika on 27/01/24.
//

import Foundation

class GestureCreationModel: ObservableObject {
    @Published var gestureModels: [GestureModel]

    init() {
        self.gestureModels = [
            GestureModel(),
            GestureModel(),
            GestureModel()
        ]
    }

    func uploadGestures(category: String = "default") {
        // Create the URL
        guard let url = URL(string: "https://gesture-jetstream.koyeb.app/register-gesture/") else { return }
        
        // Prepare the multipart request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Create the HTTP body
        var body = Data()
        
        for (index, gestureModel) in gestureModels.enumerated() {
            do {
                let jsonData = try JSONEncoder().encode(gestureModel.recordedData)
                
                let filename = "gesture\(index).json"
                body.append(convertFileData(fieldName: "files",
                                            fileName: filename,
                                            mimeType: "application/json",
                                            fileData: jsonData,
                                            using: boundary))
            } catch {
                print("Error storing file: \(error)")
            }
            
        }
        
        // Add the category part
        body.append(convertFormField(named: "category", value: category, using: boundary))
        
        // End of the body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Set the body of the request
        request.httpBody = body
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle the response here
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        // Update your UI based on the response
                        print(responseString)
                    }
                }
            }
        }.resume()
    }

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
        data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(value)\r\n".data(using: .utf8)!)

        return data
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
