//
//  UserFilterRow.swift
//  Journal
//
//  Created by Brandon Johns on 2/12/24.
//

import SwiftUI

struct UserFilterRow: View {
    var filter: Filter 
    
    /// calls the functions from SideBarView
    var rename: (Filter) -> Void
    var delete: (Filter) -> Void
    
    
    var body: some View {
        NavigationLink(value: filter) {
            ///Displays the tags and the number of active issues
            Label(filter.name, systemImage: filter.icon)
                .badge(filter.tag?.tagActiveIssues.count ?? 0)
                .contextMenu {
                    Button {
                        rename(filter)
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        delete(filter)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .accessibilityElement()
                .accessibilityLabel(filter.name)
                .accessibilityHint("^[\(filter.activeIssuesCount) issue](inflect: true)")
        }
    }
}

#Preview {
    UserFilterRow(filter: .all, rename: { _ in}, delete: {_ in})
}
