//
//  TagsMenuView.swift
//  Journal
//
//  Created by Brandon Johns on 2/12/24.
//

import SwiftUI

struct TagsMenuView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    
    var body: some View {
        Menu {
            /// show selected tags first
            ForEach(issue.issueTags) { tag in
                Button {
                    ///Method was created by CoreDatas Automatic class
                    issue.removeFromTags(tag)
                } label: {
                    Label(tag.tagName, systemImage: "checkmark")
                }
            }
            
            /// now show unselected tags
            let otherTags = dataController.missingTags(from: issue)
            
            if otherTags.isEmpty == false {
                Divider()
                
                Section("Add Tags") {
                    
                    ForEach(otherTags) { tag in
                        Button(tag.tagName) {
                            ///Method was created by CoreDatas Automatic class
                            issue.addToTags(tag)
                        }
                    }
                }
            }
        } label: {
            Text(issue.issueTagsList)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(nil, value: issue.issueTagsList)
        }
    }
}

#Preview {
    TagsMenuView(issue: .example)
        .environmentObject(DataController(inMemory: true ))
}
