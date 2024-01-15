//
//  EditView.swift
//  To Do list with SwiftData
//
//  Created by Harshit Agarwal on 20/12/23.
//

import SwiftUI
import SwiftData
import PencilKit

struct canvasView: View{
    @State  var item: newLists
    @State private var drawing = PKDrawing()
    @State private var showToolPicker = true
    
    @Environment(\.modelContext) var modelContext

    var body: some View{
        NavigationView{
            VStack{
                PKCanvasViewWrapper(drawing: $drawing, showToolPicker: $showToolPicker, saveAction: saveDrawing)
                    .edgesIgnoringSafeArea(.all) // Add this line to make it fullscreen
                    .background(Color.white)
                    .onTapGesture {
                        showToolPicker.toggle()
                    }
            }
        }
        .onAppear{
            load()
        }
    }
    
    func load(){
        // Load drawing logic
        if let data = item.drawingData as Data? {
            do {
                print(data)
                let loadedDrawing = try PKDrawing(data: data)
                drawing = loadedDrawing
                print(drawing)
            } catch {
                print("Error loading drawing: \(error)")
                // Handle the error or provide a fallback solution
            }
        } else {
            drawing = PKDrawing()
        }
    }
    func saveDrawing(drawing: PKDrawing) {
        if let data =  drawing.dataRepresentation() as Data? {
            item.drawingData = data
            try! modelContext.save()
        }
    }
}

struct EditView: View {
    @Bindable var item: newLists
    @State private var showCanvasView = false

    var title: String{
        return (item.name == "") ? "Add View" : "Edit View"
    }
    
    var body: some View {
        VStack{
            NavigationLink(destination: canvasView(item: item), isActive: $showCanvasView) {
                EmptyView()
            }
            .hidden()
            Form{
                TextField("Item Name", text: $item.name)
                
                Toggle("Private it", isOn: $item.isPrivate)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                Toggle("Add Reminder", isOn: $item.toRemind)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                
                if item.toRemind {
                    DatePicker("Remind me on", selection: $item.remindDate, displayedComponents: [.date,.hourAndMinute])
                        .font(.callout)
                    
                    Button("Remind me"){
                        activateReminder(item.remindDate, item.name, item.details, item.id)
                        //To Make Change For Private Items
                        
                    }
                }
                
                
                
                Section("Additional Notes"){
                    TextField("Note" , text: $item.details, axis: .vertical)
                        .font(.callout)
                }
                
                
            }
        }
        .onAppear(perform: {
            if item.toRemind == false {
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    print("Fetched pending notifications")
                    for index in requests.indices {
                        if requests[index].content.threadIdentifier == item.id.uuidString {
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requests[index].identifier])
                            print("Cancelled notification")
                        }
                    }
                }
            }
        })
        .navigationTitle("\(title)")
        .colorMultiply(Color(red: 247/255, green: 243/255, blue: 176/255))
        .toolbar{
            Button{
                showCanvasView = true
            }label: {
                Image(systemName: "pencil.and.scribble")
            }
    }
        .foregroundColor(.black)

//        .navigationBarTitleDisplayMode(.inline)
    }
    
}

func activateReminder(_ remindDate: Date,_ title: String, _ body: String, _ id: UUID){
    NotificationManager(remindDate: remindDate, title: title, body: body, id: id).requestAuthorization()
    NotificationManager(remindDate: remindDate, title: title, body: body, id: id).scheduleNotification()
}

#Preview {
    do{
        let schema = Schema([
            newLists.self,
        ])
        let Configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let Container = try ModelContainer(for: schema, configurations: [Configuration])
        let example = newLists(name: "Example",details: "This is the place to add note about the above items ", drawingData: PKDrawing().dataRepresentation(), isPrivate: false, addDate: Date.now, toRemind: false, remindDate: Date.now)
        
        return EditView(item: example)
            .modelContainer(Container)

    }catch{
        fatalError("Failed to load the model: \(error)")
    }
}
