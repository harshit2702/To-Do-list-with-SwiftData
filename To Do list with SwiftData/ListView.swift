//
//  ListView.swift
//  To Do list with SwiftData
//
//  Created by Harshit Agarwal on 21/12/23.
//

import SwiftUI
import SwiftData
import PencilKit

struct ListView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query var items: [newLists]
    @Query var archieved: [archieve]
    
    @State private var archieve_id = UUID()
    @State private var archieve_name = ""
    @State private var archieve_addDate =  Date.now
    @State private var archieve_details = ""
    @State private var archieve_drawingData = PKDrawing().dataRepresentation()
    @State private var archieve_isPrivate = false
    @State private var archieve_archievingDate = Date.now
        
    @Binding var isUnlocked: Bool
    @Binding var isActivateDeleteAll: Bool
    
    @State private var showingActionSheet = false
    
    var body: some View {
        List{
            ForEach(items){item in
                if(isUnlocked || !item.isPrivate){
                    NavigationLink(value: item){
                        HStack{
                            VStack(alignment: .leading){
                                Text(item.name)
                                    .font(.title3)
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            showingActionSheet = true
                                        } label: {
                                            Label("Remind ", systemImage: "clock.fill")
                                        }
                                        .tint(.indigo)
                                    }
                                    .swipeActions {
                                        Button {
                                            archieve_id = item.id
                                            archieve_name = item.name
                                            archieve_addDate = item.addDate
                                            archieve_details = item.details
                                            archieve_drawingData = item.drawingData ?? PKDrawing().dataRepresentation()
                                            archieve_isPrivate = item.isPrivate
                                            archieve_archievingDate = Date.now
                                            
                                            let archievingDate = archieve(id: archieve_id, name: archieve_name, details: archieve_details, drawingData: archieve_drawingData, isPrivate: archieve_isPrivate, addDate: archieve_addDate, archievingDate: archieve_archievingDate)
                                            modelContext.insert(archievingDate)
                                            print("here")
                                            
                                            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                                                print("Fetched pending notifications")
                                                for index in requests.indices {
                                                    if requests[index].content.threadIdentifier == item.id.uuidString {
                                                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requests[index].identifier])
                                                        print("Cancelled notification")
                                                    }
                                                }
                                            }
                                            modelContext.delete(item)
                                            print("Archieve Item")
                                            print(archieved.count)
                                        } label: {
                                            Label("Archeive", systemImage: "archivebox.fill")
                                        }
                                        .tint(.purple)
                                        
                                        Button {
                                            print("Muting conversation")
                                        } label: {
                                            Label("Mute", systemImage: "bell.slash.fill")
                                        }
                                        .tint(.indigo)
                                    }
                                    .actionSheet(isPresented: $showingActionSheet) {
                                        let currentDate = Date()
                                        let currentHour = Calendar.current.component(.hour, from: currentDate)
                                        
                                        var buttons: [ActionSheet.Button] = [
                                            .default(Text("1 Hour"), action: {
                                                print("Remind in 1 hour")
                                                item.toRemind = true
                                                let remindDate = currentDate.addingTimeInterval(3600)
                                                item.remindDate = remindDate
                                                activateReminder(item.remindDate, item.name, item.details, item.id)
                                            }),
                                            .default(Text("2 Hours"), action: {
                                                print("Remind in 2 hours")
                                                item.toRemind = true
                                                let remindDate = currentDate.addingTimeInterval(7200)
                                                item.remindDate = remindDate
                                                activateReminder(item.remindDate, item.name, item.details, item.id)
                                            }),
                                            .cancel()
                                        ]
                                        
                                        if currentHour < 21 {
                                            buttons.insert(.default(Text("Tonight"), action: {
                                                item.toRemind = true
                                                var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                                                    dateComponents.hour = 21
                                                    dateComponents.minute = 0
                                                let remindDate = Calendar.current.date(from: dateComponents)
                                                item.remindDate = remindDate!
                                                activateReminder(item.remindDate, item.name, item.details, item.id)
                                                print("Remind tonight")
                                            }), at: 2)
                                        }
                                        
                                        return ActionSheet(title: Text("Remind Time"), buttons: buttons)
                                }
                                Text("\(item.addDate.formatted(.dateTime.month(.abbreviated).day(.twoDigits)))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if item.isPrivate {
                                VStack{
                                    Spacer()
                                    Text("Private")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                }
            }
//            .onDelete(perform: deleteItems)
        }
        .onChange(of: isActivateDeleteAll) {
            deleteAll()
        }
    }
    
//    func deleteItems(offsets: IndexSet) {
//        var itemId = UUID()
//        withAnimation {
//            for index in offsets {
//                itemId = items[index].id
//                modelContext.delete(items[index])
//            }
//            print("Deleted items")
//        }
//        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
//            print("Fetched pending notifications")
//            for index in requests.indices {
//                if requests[index].content.threadIdentifier == itemId.uuidString {
//                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requests[index].identifier])
//                    print("Cancelled notification")
//                }
//            }
//        }
//    }

    func deleteAll(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for index in items.indices{
            modelContext.delete(items[index])
        }
    }
    
    init(sort: SortDescriptor<newLists>, isUnlocked: Binding<Bool>, isActivateDeleteAll: Binding<Bool>, searchString: String) {
        var sorts: [SortDescriptor<newLists>] = [sort]
        _items = Query( filter: #Predicate{
            searchString.isEmpty ? true : $0.name.localizedStandardContains(searchString)
        } ,sort: sorts)
        
        self._isUnlocked = isUnlocked
        _isActivateDeleteAll = isActivateDeleteAll
        
    }

}
//
//#Preview {
//    ListView(sort: SortDescriptor(\newLists.addDate), isUnlocked: false)
//}
