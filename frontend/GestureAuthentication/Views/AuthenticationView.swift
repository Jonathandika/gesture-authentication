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
    
    @State private var selectedGesture = 0

    var body: some View {
        VStack {
            
            Spacer()
            
            VStack {
                Text("Stored Gesture")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding([.top], 10)
                
                
                Picker("Gesture", selection: $selectedGesture) {
                    Text("Gesture 1").tag(0)
                    Text("Gesture 2").tag(1)
                    Text("Gesture 3").tag(2)
                }
                .pickerStyle(MenuPickerStyle())
                .padding(0)

                
                Chart {
                    ForEach(authenticationModel.storedGestureData[selectedGesture].indices, id: \.self) { index in
                        let motionData = authenticationModel.storedGestureData[selectedGesture][index]
                        let xValue = motionData.acceleration.x
                        let yValue = motionData.acceleration.y
                        let zValue = motionData.acceleration.z

                        LineMark(
                            x: .value("Index", index),
                            y: .value("X", xValue),
                            series: .value("Axis", "X")
                        )
                        .foregroundStyle(.red)

                        LineMark(
                            x: .value("Index", index),
                            y: .value("Y", yValue),
                            series: .value("Axis", "Y")
                        )
                        .foregroundStyle(.green)

                        LineMark(
                            x: .value("Index", index),
                            y: .value("Z", zValue),
                            series: .value("Axis", "Z")
                        )
                        .foregroundStyle(.blue)
                    }
                }
                .chartLegend(position: .topLeading)
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
                
                if (gestureRecorder.recordedData.count > 0) {
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
                } else {
                    Chart {
                        LineMark(
                            x: .value("Index", 0),
                            y: .value("X", 0),
                            series: .value("Axis", "X")
                        )
                        .foregroundStyle(.red)

                        LineMark(
                            x: .value("Index", 0),
                            y: .value("Y", 0),
                            series: .value("Axis", "Y")
                        )
                        .foregroundStyle(.green)

                        LineMark(
                            x: .value("Index", 0),
                            y: .value("Z", 0),
                            series: .value("Axis", "Z")
                        )
                        .foregroundStyle(.blue)
                    }
                    .chartLegend(position: .top, alignment: .leading, spacing: 8)
                    .frame(height: 100)
                }
                
                
                HStack {
                    LegendView(color: .red, text: "X Axis")
                    LegendView(color: .green, text: "Y Axis")
                    LegendView(color: .blue, text: "Z Axis")
                }
            }
            
            Spacer()
            
            Button(action: {
                if !gestureRecorder.isRecording {
                    authenticationModel.authenticationResult = nil
                    authenticationModel.comparisonTime = nil
                }
                gestureRecorder.toggleRecording()
            }) {
                Text(gestureRecorder.isRecording ? "Stop Recording" : "Start Recording")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Picker("Algorithm", selection: $authenticationModel.selectedAlgorithm) {
                Text("DTW").tag(AuthenticationModel.GestureComparisonAlgorithm.DTW)
                Text("FastDTW").tag(AuthenticationModel.GestureComparisonAlgorithm.FastDTW)
                Text("CTW").tag(AuthenticationModel.GestureComparisonAlgorithm.CTW)
                Text("SoftDTW").tag(AuthenticationModel.GestureComparisonAlgorithm.SoftDTW)
                Text("Euclidean").tag(AuthenticationModel.GestureComparisonAlgorithm.Euclidean)
            }
            .pickerStyle(MenuPickerStyle())

            Button("Compare Gestures") {
                gestureRecorder.stopRecording()
                authenticationModel.compareGestures(newGesture: gestureRecorder.recordedData)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
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
            if let score = authenticationModel.distanceScore {
                Text("Distance: \(score)")
                    .padding(10)
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
//
//#Preview {
//    AuthenticationView()
//}
//
//
