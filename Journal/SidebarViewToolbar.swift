//
//  SidebarViewToolbar.swift
//  Journal
//
//  Created by Brandon Johns on 2/12/24.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @Binding var showingAwards: Bool
    
    var body: some View {
        Button(action: dataController.newTag) {
            Label("Add Tag", systemImage: "plus")
        }
        
        Button {
            showingAwards.toggle()
        } label: {
            Label("Show Awards", systemImage: "rosette")
        }

        //Only seen in debug wont be shown on the app store
#if DEBUG
        Button {
            dataController.deleteAll()
            dataController.createSampleData()
        } label: {
            Label("ADD SAMPLES", systemImage: "flame")
        }
#endif
    }
}

#Preview {
    SidebarViewToolbar(showingAwards: .constant(true))
}
