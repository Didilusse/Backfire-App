//
//  VoltageInfoView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/15/25.
//
import SwiftUI

struct VoltageInfoView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        HStack {
            Image(systemName: "bolt.fill")
                .font(.title)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading) {
                Text("Voltage")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("\(bluetoothManager.voltage, specifier: "%.1f") V")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}
