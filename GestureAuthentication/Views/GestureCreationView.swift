//
//  GestureCreationView.swift
//  GestureAuthentication
//
//  Created by Jonathan Andika on 20/01/24.
//

import Foundation
import SwiftUI
import Charts

struct GestureCreationView: View {
    @ObservedObject var gestureModel = GestureModel()
    @State private var showingAlert = false
    @State private var navigateToAuthentication = false

    var body: some View {
        NavigationStack {
            VStack {
                
                Spacer()
                
                VStack{
                    Button(action: {
                        gestureModel.toggleRecording()
                    }) {
                        Text(gestureModel.isRecording ? "Stop Recording" : "Start Recording")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Text("Recorded Data Points: \(gestureModel.recordedData.count)")
                        .padding([.top], 10)
                }
    
                Spacer()
                
                VStack {
                    Text("X-Axis")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding([.top], 10)
                    Divider()
                    Chart {
                        ForEach(gestureModel.recordedData.indices, id: \.self) { index in
                            LineMark(
                                x: .value("Time", index),
                                y: .value("X", gestureModel.recordedData[index].acceleration.x),
                                series: .value("Axis", "X")
                            )
                            
                            .foregroundStyle(.red)
                        }
                    }
                    .frame(height: 100)
                    
                    Text("Y-Axis")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding([.top], 10)
                    Divider()
                    Chart {
                        ForEach(gestureModel.recordedData.indices, id: \.self) { index in
                            LineMark(
                                x: .value("Time", index),
                                y: .value("Y", gestureModel.recordedData[index].acceleration.y),
                                series: .value("Axis", "Y")
                            )
                            
                            .foregroundStyle(.green)
                        }
                    }
                    .frame(height: 100)
                    
                    Text("Z-Axis")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding([.top], 10)
                    Divider()
                    Chart {
                        ForEach(gestureModel.recordedData.indices, id: \.self) { index in
                            LineMark(
                                x: .value("Time", index),
                                y: .value("Z", gestureModel.recordedData[index].acceleration.z),
                                series: .value("Axis", "Z")
                            )
                            
                            .foregroundStyle(.blue)
                        }
                    }
                    .frame(height: 100)
                }
                
                Spacer()
                
                
                HStack {
                    Button(action: {
                        gestureModel.resetRecording()
                    }) {
                        Text("Reset Recording")
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button("Store Gesture") {
                        gestureModel.stopRecording()
                        gestureModel.saveDataToFile()

                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                }
                .padding()
                
            }
            .navigationBarTitle("Gesture Creation")
            .alert(isPresented: $gestureModel.isSaveSuccessful) {
                Alert(
                    title: Text("Success"),
                    message: Text("Gesture stored successfully! \nDo you want to authenticate?"),
                    primaryButton: .default(Text("Retry")) {
                        // Simply dismiss the alert
                    },
                    secondaryButton: .default(Text("Verify")) {
                        // Trigger navigation to AuthenticationView
                        self.navigateToAuthentication = true
                    }
                )
            }
            .navigationDestination(isPresented: $navigateToAuthentication) {
                AuthenticationView()
            }
        }
    }
}

#Preview {
    GestureCreationView()
}
