//
//  Item.swift
//  To Do list with SwiftData
//
//  Created by Harshit Agarwal on 20/12/23.
//

import Foundation
import SwiftData

@Model
class newLists: Identifiable {
    
    var id: UUID
    var name: String
    var details: String
    var isPrivate: Bool
    var addDate: Date
    var toRemind: Bool
    var remindDate: Date
    
    init(id: UUID = UUID() ,name: String = "", details: String = "" , isPrivate: Bool = false, addDate: Date = Date.now, toRemind: Bool = false, remindDate: Date = Date.now) {
        self.id = id
        self.name = name
        self.details = details
        self.isPrivate = isPrivate
        self.addDate = addDate
        self.toRemind = toRemind
        self.remindDate = remindDate
    }
    
    
}
