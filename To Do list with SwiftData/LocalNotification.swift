//
//  LocalNotification.swift
//  To Do list with SwiftData
//
//  Created by Harshit Agarwal on 21/12/23.
//

import SwiftUI
import SwiftData
//import CoreLocation

//@Model
class NotificationManager {
    
//    static let instance = NotificationManager(remindDate: Date())
    var remindDate: Date = Date.now
    var id: UUID = UUID()
    var title: String = "Title"
    var body: String = "Body"
    
    func requestAuthorization(){
        let options: UNAuthorizationOptions = [.alert, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { Success, Error in
            if let error = Error {
                print("Error: \(error)")
            }else{
                print("Success")
            }
        }
    }
    init(remindDate : Date, title: String, body: String, id: UUID){
        self.id = id
        self.remindDate = remindDate
        self.title = title
        self.body = body
    }
    func scheduleNotification(){
        let content = UNMutableNotificationContent()
        content.threadIdentifier = id.uuidString
        content.title = title
        content.body = body
        content.sound = .default
        
        
    //Time:-
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
    //Calander:-
        var dateComponents  =  Calendar.current.dateComponents([.year,.month, .day, .hour, .minute], from: remindDate)

//        dateComponents.month = remindDate.dateComponents([.month]).month
//        dateComponents.day = 22
//        dateComponents.hour = 23
//        dateComponents.minute = 4
//        dateComponents.weekday = 1 // Sunday = 0
        let trigger2 = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
    //Location:-
//        let coordinates = CLLocation(latitude: <#T##CLLocationDegrees#>, longitude: <#T##CLLocationDegrees#>)
//        let region = CLCircularRegion(center: <#T##CLLocationCoordinate2D#>, radius: <#T##CLLocationDistance#>, identifier: <#T##String#>)
//        region.notifyOnEntry = true
//        region.notifyOnExit = true
//        let trigger3 = UNLocationNotificationTrigger(region: <#T##CLRegion#>, repeats: false)
        
        
        let request = UNNotificationRequest(identifier: content.threadIdentifier,
                                            content: content,
                                            trigger: trigger2)
        UNUserNotificationCenter.current().add(request)
        print(id)
        print(dateComponents)
    }
//    func cancelNotification(){
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//
//        
//    }
//    func getPendingNotification()  -> [UNNotificationRequest] {
//         var pendingNotificationRequests: [UNNotificationRequest] = []
//
//        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
////            print(requests)
//
//            pendingNotificationRequests.insert(contentsOf: requests, at: pendingNotificationRequests.endIndex)
//        }
//        return pendingNotificationRequests
//    }
    func getPendingNotification(completion: @escaping ([UNNotificationRequest]) -> Void) {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                DispatchQueue.main.async {
                    completion(requests)
                }
            }
        }
    func cancelNotification(identifiers: [String]) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
}

struct LocalNotification: View {
    @State private var setRemindDate = Date(timeInterval: 120, since: Date.now)
    @State private var animateButton = true
    
    @Query var items: [newLists]
    
    @State private var pendingNotificationRequests: [UNNotificationRequest] = []

    var body: some View {
        VStack{
            List{
                ForEach(pendingNotificationRequests, id: \.identifier) { request in
                    VStack{
                        HStack{
                            Text("\(request.content.title)")
                                .font(.title3)
                            if let calenderTrigger = request.trigger as? UNCalendarNotificationTrigger {
                                let nextTriggerdate = calenderTrigger.nextTriggerDate()
                                Text("\(nextTriggerdate?.formatted(date: .abbreviated, time: .shortened) ?? Date().formatted(date: .abbreviated, time: .omitted))")
                            }
                        }
                        Text("\(request.content.body) ")
                            .font(.caption)
                        // Display other information about the notification request as needed
                        
                    }
                    
                }
                .onDelete(perform: deleteNotification)
            }
            
            //        Form{
            //            Button("Request Permission"){
            //                //            NotificationManager.instance.requestAuthorization()
            //                //            NotificationManager(remindDate: setRemindDate).requestAuthorization()
            //            }
            //            Button("Schedule notificcation"){
            //                //            NotificationManager.instance.scheduleNotification()
            //                //            NotificationManager(remindDate: setRemindDate).scheduleNotification()
            //                animateButton.toggle()
            //            }
            //            .scaleEffect(animateButton ? 0.9 : 1.0) // Apply scale effect when pressed
            //            .opacity(animateButton ? 0.8 : 1.0) // Reduce opacity when pressed
            //            .animation(.easeInOut(duration: 0.1))
            //        }
        }
        .onAppear{
//            UIApplication.shared.applicationIconBadgeNumber = 0
            let notificationManager = NotificationManager(remindDate: Date(), title: "Title", body: "body", id: UUID())
            notificationManager.getPendingNotification { requests in
                    self.pendingNotificationRequests = requests
                }
        }
        .colorMultiply(Color(red: 247/255, green: 243/255, blue: 176/255))
    }
    
    func deleteNotification(offsets: IndexSet){
        let notificationManager = NotificationManager(remindDate: Date(), title: "Title", body: "body", id: UUID())

        for index in offsets {
            var uuid = pendingNotificationRequests[index].identifier
            print(uuid)
            for itemIndex in items.indices{
                if items[itemIndex].id.uuidString == uuid{
                    items[itemIndex].toRemind = false
                }
            }
            notificationManager.cancelNotification(identifiers: [pendingNotificationRequests[index].identifier])
            
            
        }
    }
    
}

#Preview {
    LocalNotification()
}
