//
//  AuthenticationView.swift
//  GestureAuthentication
//
//  Created by Jonathan Andika on 21/01/24.
//

import Foundation
import SwiftUI
import Charts

struct AuthenticationView: View {
    @StateObject private var authenticationModel = AuthenticationModel()
    @ObservedObject var gestureRecorder = GestureModel()

    var body: some View {
        VStack {
            
            Spacer()
            
            VStack {
                Text("Stored Gesture")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding([.top], 10)
                    
                Chart {
                    ForEach(authenticationModel.gestureModel.storedGestureData.indices, id: \.self) { index in
                        LineMark(
                            x: .value("Index", index),
                            y: .value("X", authenticationModel.gestureModel.storedGestureData[index].acceleration.x),
                            series: .value("Axis", "X")
                        )
                        .foregroundStyle(.red)

                        LineMark(
                            x: .value("Index", index),
                            y: .value("Y", authenticationModel.gestureModel.storedGestureData[index].acceleration.y),
                            series: .value("Axis", "Y")
                        )
                        .foregroundStyle(.green)

                        LineMark(
                            x: .value("Index", index),
                            y: .value("Z", authenticationModel.gestureModel.storedGestureData[index].acceleration.z),
                            series: .value("Axis", "Z")
                        )
                        .foregroundStyle(.blue)
                    }
                }
                .chartLegend(position: .top, alignment: .leading, spacing: 8)
                .frame(height: 100)
                
                HStack {
                    LegendView(color: .red, text: "X Axis")
                    LegendView(color: .green, text: "Y Axis")
                    LegendView(color: .blue, text: "Z Axis")
                }
            }
            
            VStack {
                Text("New Gesture")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding([.top], 10)
                
                Chart {
                    ForEach(gestureRecorder.recordedData.indices, id: \.self) { index in
                        LineMark(
                            x: .value("Index", index),
                            y: .value("X", gestureRecorder.recordedData[index].acceleration.x),
                            series: .value("Axis", "X")
                        )
                        .foregroundStyle(.red)

                        LineMark(
                            x: .value("Index", index),
                            y: .value("Y", gestureRecorder.recordedData[index].acceleration.y),
                            series: .value("Axis", "Y")
                        )
                        .foregroundStyle(.green)

                        LineMark(
                            x: .value("Index", index),
                            y: .value("Z", gestureRecorder.recordedData[index].acceleration.z),
                            series: .value("Axis", "Z")
                        )
                        .foregroundStyle(.blue)
                    }
                }
                .chartLegend(position: .top, alignment: .leading, spacing: 8)
                .frame(height: 100)
                
                HStack {
                    LegendView(color: .red, text: "X Axis")
                    LegendView(color: .green, text: "Y Axis")
                    LegendView(color: .blue, text: "Z Axis")
                }
            }
            
            Spacer()
            
            Button(action: {
                gestureRecorder.toggleRecording()
            }) {
                Text(gestureRecorder.isRecording ? "Stop Recording" : "Start Recording")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Picker("Algorithm", selection: $authenticationModel.selectedAlgorithm) {
                Text("Default Algorithm").tag(AuthenticationModel.GestureComparisonAlgorithm.defaultAlgorithm)
                Text("DTW").tag(AuthenticationModel.GestureComparisonAlgorithm.DTW)
                Text("FastDTW").tag(AuthenticationModel.GestureComparisonAlgorithm.FastDTW)
                Text("PrunedDTW").tag(AuthenticationModel.GestureComparisonAlgorithm.PrunedDTW)
                Text("Protractor3D").tag(AuthenticationModel.GestureComparisonAlgorithm.Protractor3D)
                Text("GlobalSequenceAlignment").tag(AuthenticationModel.GestureComparisonAlgorithm.GlobalSequenceAlignment)
            }
            .pickerStyle(MenuPickerStyle())

            Button("Compare Gestures") {
                authenticationModel.compareGestures(newGesture: gestureRecorder.recordedData)
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
            
            // Display the result and comparison time
            if let result = authenticationModel.authenticationResult {
                if (result == true) {
                    Text("Gesture Matched !")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                } else {
                    Text("Gesture Not Matched !")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.red)
                }
                
            }
            if let time = authenticationModel.comparisonTime {
                Text("Comparison Time: \(time) seconds")
                    .padding(10)
            }
            
            Spacer()
        }
        .navigationBarTitle("Authenticate Gesture", displayMode: .inline)
    }
}

struct LegendView: View {
    var color: Color
    var text: String

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 20, height: 6)
            Text(text)
        }
    }
}

#Preview {
    AuthenticationView()
}
