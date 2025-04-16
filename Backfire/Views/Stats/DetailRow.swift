//
//  DetailRow.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/16/25.
//

import SwiftUI
import MapKit

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

// Fix preview
#Preview {
    DetailRow(title: "Test", value: "Value")
        .padding()
}
