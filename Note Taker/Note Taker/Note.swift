//
//  Note.swift
//  
//
//  Created by Stephen DeStefano on 6/10/15.
//
//

import Foundation
import CoreData

class Note: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var url: String

}
