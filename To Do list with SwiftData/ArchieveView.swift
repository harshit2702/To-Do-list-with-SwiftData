//
//  ArchieveView.swift
//  To Do list with SwiftData
//
//  Created by Harshit Agarwal on 14/01/24.
//

import SwiftUI
import SwiftData

struct ArchieveView: View {
    @Environment(\.modelContext) var modelContext

    @Query var archieved: [archieve]

    var body: some View {
        List{
            ForEach(archieved){item in
                NavigationLink(value: item){
                    HStack{
                        VStack(alignment: .leading){
                            Text(item.name)
                                .font(.title3)
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
            .onDelete(perform: deleteItems)
        }
    }
    func deleteItems(offsets: IndexSet) {
        var itemId = UUID()
        withAnimation {
            for index in offsets {
                itemId = archieved[index].id
                modelContext.delete(archieved[index])
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
}

#Preview {
    ArchieveView()
}
