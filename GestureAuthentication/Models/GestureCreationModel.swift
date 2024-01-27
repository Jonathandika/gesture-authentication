//
//  GestureCreationModel.swift
//  GestureAuthentication
//
//  Created by Jonathan Andika on 27/01/24.
//

import Foundation

class GestureCreationModel: ObservableObject{
    @Published var gestureModels: [GestureModel]

    init(){
        self.gestureModels = [
            GestureModel(),
            GestureModel(),
            GestureModel()
        ]
    }
}
