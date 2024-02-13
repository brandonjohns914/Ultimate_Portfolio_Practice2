//
//  Issue-CoreDataHelpers.swift
//  Journal
//
//  Created by Brandon Johns on 2/5/24.
//

import Foundation

///Extension Issue class created automattically
/// getting and settting values to get around CoreDatas optionality
extension Issue {
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }

    var issueCreationDate: Date {
        creationDate ?? .now
    }

    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    
    ///Selected Tags 
    ///NSSET relationship between Issues and Tags
    /// sorts all the Issues Into Tags
    /// if there arent any tags then send back and empty array
    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    

    var issueStatus: String {
        if completed {
            return "Closed"
        } else {
            return "Open"
        }
    }
    
    var issueFormattedCreationDate: String {
        issueCreationDate.formatted(date: .numeric, time: .omitted)
    }
    
    ///Converts the selected Tags (issueTags)  into an array of just Tag names
    var issueTagsList: String {
        /// tags == NSSet from CoreData created class
        guard let tags else { return "No Tags" }

        if tags.count == 0 {
            return "No Tags"
        } else {
            return issueTags.map(\.tagName).formatted()
        }
    }
    
    ///Example Isssue to be used in preview
    static var example: Issue {
        /// Uses in memory to make sure the example is only temporary
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        
        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.creationDate = .now
        return issue
    }
}
/// Compares Issue by title if titles are the same then it compares it by the creationdate
extension Issue: Comparable {
    public static func <(lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        } else {
            return left < right
        }
    }
}
