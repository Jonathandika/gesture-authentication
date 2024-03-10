//
//  GestureCreationView.swift
//  GestureAuthentication
//
//  Created by Jonathan Andika on 20/01/24.
//

import Foundation
import SwiftUI

struct GestureCreationView: View {
    @ObservedObject var gestureCreationModel = GestureCreationModel()
    
    @State private var showingAlert = false
    @State private var navigateToAuthentication = false
    @State private var gestureCreationStep:Int = 0
    @State private var gestureCreationFinished = false

    var body: some View {
        NavigationStack {
            VStack {
                
                Spacer()
                
                VStack {
                    ForEach((0...2), id:\.self) { gestureID in
                        Text("Gesture \(gestureID + 1)")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding([.top], 10)
                        GestureChartView(gestureModel: gestureCreationModel.gestureModels[gestureID])
                    }
                }
                
                Spacer()
                
                VStack{
                    
                    GestureDataPointsCountView(gestureModel: gestureCreationModel.gestureModels[gestureCreationStep])
                    
                    Button(action: {
                        self.gestureCreationModel.objectWillChange.send()
                        gestureCreationModel.gestureModels[gestureCreationStep].toggleRecording()
                    }) {
                        Text(gestureCreationModel.gestureModels[gestureCreationStep].isRecording ? "Stop Recording" : "Start Recording")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                   
                }.padding(.bottom, 10)
    
                Spacer()
                
                Divider()
                
                HStack {
                    Spacer()
                    
                    Text("Gesture 1")
                    if (gestureCreationStep >= 1) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color.green)
                    }
                    else {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(Color.red)
                    }
                    
                    
                    
                    Spacer()
                    
                    Text("Gesture 2")
                    if (gestureCreationStep >= 2) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color.green)
                    }
                    else {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(Color.red)
                    }
                    
                    Spacer()
                    
                    Text("Gesture 3")
                    if (gestureCreationFinished) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color.green)
                    }
                    else {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(Color.red)
                    }
                    
                    Spacer()
                }.padding([.top, .bottom], 5)
                Divider()
                
                HStack {
                    Button(action: {
                        self.gestureCreationModel.objectWillChange.send()
                        gestureCreationModel.gestureModels[gestureCreationStep].resetRecording()
                    }) {
                        Text("Reset Recording")
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button("Store Gesture") {
                        self.gestureCreationModel.objectWillChange.send()
                        gestureCreationModel.gestureModels[gestureCreationStep].stopRecording()
                        gestureCreationModel.gestureModels[gestureCreationStep]
                            .saveDataToFile(
                                gestureData: gestureCreationModel.gestureModels[gestureCreationStep].recordedData,
                                gestureDataName: "gestureData_\(gestureCreationStep + 1)"
                            )
                        if (self.gestureCreationStep >= 2) {
                            // Upload to Server
                            gestureCreationModel.uploadGestures()
                            self.gestureCreationFinished = true
                        }
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                }
                .padding()
                
            }
            .navigationBarTitle("Gesture Creation")
            .alert(isPresented: $gestureCreationModel.gestureModels[gestureCreationStep].isSaveSuccessful) {
                
                if (self.gestureCreationStep >= 2) {
                    return Alert(
                        title: Text("Success"),
                        message: Text("Gestures stored successfully! \nDo you want to authenticate?"),
                        primaryButton: .default(Text("Retry")) {
                            self.gestureCreationStep -= 1
                        },
                        secondaryButton: .default(Text("Verify")) {
                            // Trigger navigation to AuthenticationView
                            self.navigateToAuthentication = true
                        }
                    )
                }
                else {
                    return Alert(
                        title: Text("Success"),
                        message: Text("Gesture stored successfully! \nPlease record the next gesture!"),
                        primaryButton: .default(Text("Retry")) {

                        },
                        secondaryButton: .default(Text("OK")) {
                            // Trigger navigation to AuthenticationView
                            self.gestureCreationStep += 1
                        }
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToAuthentication) {
                AuthenticationView()
            }
        }
    }
}

struct GestureDataPointsCountView: View {
    @ObservedObject var gestureModel: GestureModel

    var body: some View {
        Text("Recorded Data Points: \(gestureModel.recordedData.count)")
                                .padding([.top], 10)
    }
}



#Preview {
    GestureCreationView()
}
