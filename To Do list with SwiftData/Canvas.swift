//
//  Canvas.swift
//  To Do list with SwiftData
//
//  Created by Harshit Agarwal on 30/12/23.
//

import SwiftUI
import SwiftData
import PencilKit

struct Canvas: View {
    @Environment(\.modelContext) var modelContext
    @State private var drawing = PKDrawing()
    @State private var drawingData: Data?
    @State private var showEditView = false
    @State private var showToolPicker = true
    @State private var count = 0

    @State var item: newLists
    
    var body: some View {
        VStack{
            NavigationLink(destination: EditView(item: item), isActive: $showEditView) {
                EmptyView()
            }
            .hidden()
            PKCanvasViewWrapper(drawing: $drawing, showToolPicker: $showToolPicker, saveAction: saveDrawing)//savedrawing should be of type (PKDrawing) -> Void
                .edgesIgnoringSafeArea(.all)
                .background(Color.white)
                .onTapGesture {
                    showToolPicker.toggle()
                }
                .navigationBarTitle("Scratch Pad", displayMode: .inline)
            
                .toolbar{
                    
                    Button("save"){
                        saveMemory()
                    }
                    Button("Edit"){
                        showEditView = true
                    }
            }
        }
        .onAppear{
            if count == 0 {
                drawingData = item.drawingData
                load()
                count = 1
            }
        }
    }
    
    func load(){
        // Load drawing logic
        if let data = drawingData as Data? {
            do {
                print(data)
                let loadedDrawing = try PKDrawing(data: data)
                drawing = loadedDrawing
            } catch {
                print("Error loading drawing: \(error)")
                // Handle the error or provide a fallback solution
            }
        } else {
            drawing = PKDrawing()
        }
    }
    
    func saveDrawing(drawing: PKDrawing) {
        // Save drawing logic
        if let data =  drawing.dataRepresentation() as Data? {
            drawingData = data
        }
    }
    func saveMemory(){
        item.drawingData = drawingData
        print(drawingData)
        modelContext.insert(item)
        count = 0
    }
}

#Preview {
    do{
        let schema = Schema([
            newLists.self,
        ])
        let Configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let Container = try ModelContainer(for: schema, configurations: [Configuration])
        let example = newLists(name: "Example",details: "This is the place to add note about the above items ", drawingData: PKDrawing().dataRepresentation(), isPrivate: false, addDate: Date.now, toRemind: false, remindDate: Date.now)
        
        return Canvas(item: example)
            .modelContainer(Container)

    }catch{
        fatalError("Failed to load the model: \(error)")
    }
}
