//
//  ContentView.swift
//  GestureAuthentication
//
//  Created by Jonathan Andika on 20/01/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        GestureCreationView()
    }

   
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
