//
//  DashboardView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/15/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Zealot Dashboard")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                ConnectionStatusIndicator()
            }
            .padding()
            
            // Main telemetry
            ScrollView {
                VStack(spacing: 20) {
                    SpeedometerView()
                    BatteryInfoView()
                    DistanceStatsView()
                    VoltageInfoView()
                }
                .padding()
            }
        }
        .overlay(alignment: .bottom) {
            if bluetoothManager.targetPeripheral == nil {
                ReconnectButton()
            }
        }
    }
    
    @ViewBuilder
    private func ConnectionStatusIndicator() -> some View {
        HStack {
            Circle()
                .fill(bluetoothManager.targetPeripheral != nil ? Color.green : Color.red)
                .frame(width: 10, height: 10)
            
            Text(bluetoothManager.targetPeripheral?.name ?? "Disconnected")
                .font(.subheadline)
        }
    }
    
    @ViewBuilder
    private func ReconnectButton() -> some View {
        Button {
            bluetoothManager.startScan()
        } label: {
            Label("Reconnect Board", systemImage: "arrow.clockwise")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding()
    }
}


#Preview {
    DashboardView()
        .environmentObject(BluetoothManager.shared)
}
