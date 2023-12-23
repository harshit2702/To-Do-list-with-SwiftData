//
//  EditView.swift
//  To Do list with SwiftData
//
//  Created by Harshit Agarwal on 20/12/23.
//

import SwiftUI
import SwiftData

struct EditView: View {
    @Bindable var item: newLists
    
    var title: String{
        return (item.name == "") ? "Add View" : "Edit View"
    }
    
    var body: some View {
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
        .navigationTitle("\(title)")
        .colorMultiply(Color(red: 247/255, green: 243/255, blue: 176/255))
        .foregroundColor(.black)

//        .navigationBarTitleDisplayMode(.inline)
    }
    
    func activateReminder(_ remindDate: Date,_ title: String, _ body: String, _ id: UUID){
        NotificationManager(remindDate: remindDate, title: title, body: body, id: id).requestAuthorization()
        NotificationManager(remindDate: remindDate, title: title, body: body, id: id).scheduleNotification()
    }
}

#Preview {
    do{
        let schema = Schema([
            newLists.self,
        ])
        let Configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let Container = try ModelContainer(for: schema, configurations: [Configuration])
        let example = newLists(name: "Example",details: "This is the place to add note about the above items ", isPrivate: false, addDate: Date.now, toRemind: false, remindDate: Date.now)
        
        return EditView(item: example)
            .modelContainer(Container)

    }catch{
        fatalError("Failed to load the model: \(error)")
    }
}
