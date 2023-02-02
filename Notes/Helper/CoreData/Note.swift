//
//  Note.swift
//  Notes
//
//  Created by Дмитрий Корчагин on 02.02.2023.
//

import CoreData

var noteList = [Note]()


@objc(Note)
class Note: NSManagedObject{
    
    @NSManaged var id: NSNumber!
    @NSManaged var name: String!
    @NSManaged var details: String!
    @NSManaged var deletedDate: Date?
    
}
