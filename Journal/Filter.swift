//
//  Filter.swift
//  Journal
//
//  Created by Brandon Johns on 2/4/24.
//

import Foundation



/// How to sort the view when opening the app
/// Filters the view between .recent and .all
struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    ///filters based on time so by default all issues should show up
    var minModificationDate = Date.distantPast
    
    /// filter by specific tag
    var tag: Tag?
    
    var activeIssuesCount: Int {
        tag?.tagActiveIssues.count ?? 0
    }
    
    
    /// Both are filtering options to direct which view to move to
    ///all is a constant filter that shows all issues
    static var all = Filter (
        id: UUID(),
        name: "All Issues",
        icon: "tray"
    )
    
    
    /// recent filters by issues created in the last 7 days
    static var recent = Filter(
        id: UUID(),
        name: "Recent Issues",
        icon: "clock",
        minModificationDate: .now.addingTimeInterval(86400 * -7)
    )
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Compares two filters and returns true if their IDs are equal
    /// - Parameters:
    ///   - lhs: Filter one
    ///   - rhs: Filter two
    /// - Returns: true if both filter ids are equal
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
    
    
}
