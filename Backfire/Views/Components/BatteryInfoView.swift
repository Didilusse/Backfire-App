//
//  BatteryInfoView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/15/25.
//
import SwiftUI

struct BatteryInfoView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        HStack {
            Image(systemName: "battery.75")
                .font(.system(size: 40))
                .foregroundColor(batteryColor)
            
            VStack(alignment: .leading) {
                Text("Battery")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ProgressView(value: Double(bluetoothManager.battery)/100)
                    .progressViewStyle(LinearProgressViewStyle(tint: batteryColor))
                
                Text("\(bluetoothManager.battery)%")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        
    }
    
    private var batteryColor: Color {
        switch bluetoothManager.battery {
        case 0...20: return .red
        case 21...40: return .orange
        default: return .green
        }
    }
}
