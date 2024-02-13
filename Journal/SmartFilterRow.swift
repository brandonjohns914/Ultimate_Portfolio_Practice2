//
//  SmartFilterRow.swift
//  Journal
//
//  Created by Brandon Johns on 2/12/24.
//

import SwiftUI

struct SmartFilterRow: View {
    var filter: Filter
    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon )
        }
    }
}

#Preview {
    SmartFilterRow(filter: .all)
}
