//
//  ListView.swift
//  To Do list with SwiftData
//
//  Created by Harshit Agarwal on 21/12/23.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query var items: [newLists]
    
    @Binding var isUnlocked: Bool
    @Binding var isActivateDeleteAll: Bool
    
    var body: some View {
        List{
            ForEach(items){item in
                if(isUnlocked || !item.isPrivate){
                    NavigationLink(value: item){
                        HStack{
                            VStack(alignment: .leading){
                                Text(item.name)
                                    .font(.title2)
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
            .onDelete(perform: deleteItems)
        }
        .onChange(of: isActivateDeleteAll) {
            deleteAll()
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        var itemId = UUID()
        withAnimation {
            for index in offsets {
                itemId = items[index].id
                modelContext.delete(items[index])
            }
            print("Deleted items")
        }
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Fetched pending notifications")
            for index in requests.indices {
                if requests[index].content.threadIdentifier == itemId.uuidString {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [requests[index].identifier])
                    print("Cancelled notification")
                }
            }
        }
    }

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
