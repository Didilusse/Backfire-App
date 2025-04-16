//
//  DeviceConnectionView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/15/25.
//

import SwiftUI

struct DeviceConnectionView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        VStack {
            if bluetoothManager.discoveredDevices.isEmpty {
                ProgressView("Scanning for boards...")
                    .padding()
                
                Button("Retry Scan") {
                    bluetoothManager.startScan()
                }
            } else {
                List(bluetoothManager.discoveredDevices.filter { !($0.name?.isEmpty ?? true) }, id: \.identifier) { peripheral in
                    Button {
                        bluetoothManager.connectToDevice(peripheral)
                        isOnboardingComplete = true
                    } label: {
                        HStack {
                            Text(peripheral.name ?? "Unknown Board")
                            Spacer()
                            if bluetoothManager.targetPeripheral?.identifier == peripheral.identifier {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Your Board")
        .onAppear {
            bluetoothManager.startScan()
        }
    }
}

#Preview {
    DeviceConnectionView(isOnboardingComplete: .constant(false))
        .environmentObject(BluetoothManager.shared)
}
