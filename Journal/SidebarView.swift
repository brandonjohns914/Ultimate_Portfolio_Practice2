//
//  SidebarView.swift
//  Journal
//
//  Created by Brandon Johns on 2/4/24.
// Sidebar View: Primary view
//      Left most showing filters
//      default view when the app is loaded 
// Content View:  middle view showing issues
// Detail View: Showing one specific issue
//      Right most 
//      appears first in landscape mode

import SwiftUI

struct SidebarView: View {
    
    ///Creates the dataController
    @EnvironmentObject var dataController: DataController
    
    ///Two filtering view options
    let smartFilters: [Filter] = [.all, .recent]
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SidebarView()
}
