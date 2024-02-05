//
//  Tag-CoreDataHelpers.swift
//  Journal
//
//  Created by Brandon Johns on 2/5/24.
//

import Foundation

///Extension Tag class created automattically
/// Values to get around CoreDatas optionality
extension Tag {
    var tagID: UUID {
        id ?? UUID()
    }
    
    var tagName: String {
        name ?? ""
    }
    
    ///NSSET relationship between Issues and Tags
    ///Sorts Issues by completion return any issues that havent been completed
    var tagActiveIssues: [Issue] {
        let result = issues?.allObjects as? [Issue] ?? []
        return result.filter { $0.completed == false }
    }
        
        ///Example Tag to be used in preview
        static var example: Tag {
            /// Uses in memory to make sure the example is only temporary
            let controller = DataController(inMemory: true)
            let viewContext = controller.container.viewContext
            
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Example Tag"
            return tag
        }
    }

///Sorts by tagName if not sorts by ID 
extension Tag: Comparable {
    public static func <(lhs: Tag, rhs: Tag) -> Bool {
        let left = lhs.tagName.localizedLowercase
        let right = rhs.tagName.localizedLowercase
        
        if left == right {
            return lhs.tagID.uuidString < rhs.tagID.uuidString
        } else {
            return left < right
        }
    }
}
    
