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
    @ObservedObject var gestureModel = GestureCreationModel()

    var body: some View {
        NavigationView {
            VStack {
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
                }
                .padding([.bottom], 20)

                
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
                                y: .value("X", gestureModel.recordedData[index].x),
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
                                y: .value("Y", gestureModel.recordedData[index].y),
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
                                y: .value("Z", gestureModel.recordedData[index].z),
                                series: .value("Axis", "Z")
                            )
                            
                            .foregroundStyle(.blue)
                        }
                    }
                    .frame(height: 100)
                }
                
            }
            .navigationBarTitle("Gesture Creation")
        }
    }
}
