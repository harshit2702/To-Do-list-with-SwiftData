//
//  ContentView.swift
//  To Do list with SwiftData
//
//  Created by Harshit Agarwal on 20/12/23.
//

import SwiftUI
import SwiftData
import LocalAuthentication
import PencilKit

struct ContentView: View {
    @Environment(\.modelContext)  var modelContext
    
    @State private var path = [newLists]()
    
    @State private var itemName = ""
    
    @State private var isUnlocked = false
    @State private var showingAlert = false
    @State private var showPendingNotification = false
    @State private var showCanvas = false
    @State private var isActivateDeleteAll = false
    
    @State private var sortByNameCount = 0
    @State private var sortByDateCount = 1



    
    @State private var sortOrder = SortDescriptor(\newLists.addDate)
    @State private var searchText = ""

    
    var body: some View {
        NavigationSplitView{
            ZStack{
                withAnimation{
                    ListView(sort: sortOrder, isUnlocked: $isUnlocked, isActivateDeleteAll: $isActivateDeleteAll, searchString: searchText)
                        .colorMultiply(Color(red: 255/255, green: 249/255, blue: 168/255))
                }
                
                VStack{
                    NavigationLink(destination: LocalNotification(), isActive: $showPendingNotification) {
                        EmptyView()
                    }
                    .hidden()
                    NavigationLink(destination: Canvas(item: newLists(name: "Sketch \(Date.now.formatted(date: .abbreviated, time: .shortened)) ",drawingData: PKDrawing().dataRepresentation())), isActive: $showCanvas) {
                        EmptyView()
                    }
                    .hidden()
                    Spacer()
                    HStack{
                        HStack{
                            TextField("New Item", text: $itemName)
                                .padding()
                            Button{
                                addItem()
                            }label:{
                                Image(systemName: "plus")
                            }
                            .padding()
                            .font(.title)
                        }
                        .font(.callout)
                        .background(.yellow)
                        .clipShape(RoundedRectangle(cornerRadius: 30.0))
                        if itemName == "" {
                            Button{
                                showCanvas = true
                            }label:{
                                Image(systemName: "pencil.and.scribble")
                            }
                            .frame(minWidth: 50,minHeight: 50)
                            .font(.title)
                            .background(.yellow)
                            .clipShape(Circle())
                        }
                    }
                    .padding()

                }
            }
            .navigationTitle("To-Do List")
            .searchable(text: $searchText)
            .navigationDestination(for: newLists.self, destination: EditView.init)
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("Sort", systemImage: "arrow.up.arrow.down"){
                        Button{
                            sortByNameCount = inc(bySort: sortByNameCount)
                            if sortByNameCount == 0{
                                sortOrder = SortDescriptor(\newLists.id)
                            }else if sortByNameCount == 1{
                                sortOrder = SortDescriptor(\newLists.name)

                            }else if sortByNameCount == 2 {
                                sortOrder = SortDescriptor(\newLists.name, order: .reverse)
                            }
                            sortByDateCount = 0
                        }
                        label:{
                            if sortByNameCount == 0{
                                Text("Name")
                            }else if sortByNameCount == 1{
                                Text("A - Z")

                            }else if sortByNameCount == 2 {
                                Text("Z - A")
                            }
                        }
                        Button{
                            sortByDateCount = inc(bySort: sortByDateCount)
                            if sortByDateCount == 0{
                                sortOrder = SortDescriptor(\newLists.id)
                            }else if sortByDateCount == 1{
                                sortOrder = SortDescriptor(\newLists.addDate)

                            }else if sortByDateCount == 2 {
                                sortOrder = SortDescriptor(\newLists.addDate, order: .reverse)
                            }
                            sortByNameCount = 0
                        }
                        label:{
                            if sortByDateCount == 0{
                                Text("Date")
                            }else if sortByDateCount == 1{
                                Text("0 - 9")

                            }else if sortByDateCount == 2 {
                                Text("9 - 0")
                            }
                        }
                    }
                    
                }
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        EditButton()
                        Button{
                            authenticate()
                        }label:{
                            isUnlocked ? HStack {
                                Text("Unlocked")
                                Image(systemName: "lock.open")
                            } : HStack {
                                Text("Locked")
                                Image(systemName: "lock.fill")
                            }
                        }
                        Button{
                            showingAlert = true
                        }label:{
                            HStack {
                                Text("Delete")
                                Image(systemName: "multiply.circle")
                            }
                        }
                        
                        Button("Get pendingNotifications"){
                            showPendingNotification = true
                        }
                    }label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .clipShape(RoundedRectangle(cornerRadius: 15.0))
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Confirm Delete"), message: Text("Are you sure you want to delete?"), primaryButton: .destructive(Text("Delete"), action: activateDeleteAll), secondaryButton: .cancel())
                    }
                }
#endif
                
            }
        }detail: {
            Text("Details")
        }
    }
    func inc(bySort: Int) -> Int{
        return (bySort + 1) % 3
    }
    func activateDeleteAll(){
        isActivateDeleteAll.toggle()
    }
    
     func addItem() {
         if itemName != "" {
             let newItem = newLists(name: itemName, drawingData: PKDrawing().dataRepresentation())
             modelContext.insert(newItem)
             itemName = ""
         }
         //path = [newItem]
    }
    func authenticate(){
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "We need to unlock Private Item List"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){success , authenticatioError in
                if success{
                    isUnlocked = true
                }else{
                    
                }
            }
        }
        else{
            //No biometrics
        }
    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: newLists.self, inMemory: true)
}
