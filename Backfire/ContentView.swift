//
//  ContentView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var bt = BluetoothManager()
    @State private var isScanning = true
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 20) {
            if bt.targetPeripheral == nil {
                Text("Select Your Board")
                    .font(.headline)

                TextField("Search...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                List(bt.discoveredDevices.filter { device in
                    let name = device.name ?? ""
                    return !name.isEmpty &&
                           name != "Unnamed" &&
                           (searchText.isEmpty || name.localizedCaseInsensitiveContains(searchText))
                }, id: \.identifier) { device in
                    Button(device.name ?? "Unnamed") {
                        bt.connectToDevice(device)
                    }
                }
            } else {
                Text("Connected to: \(bt.targetPeripheral?.name ?? "Unknown")")
                    .font(.headline)

                Text("Voltage: \(bt.voltage, specifier: "%.2f") V")
                Text("Battery: \(bt.battery)%")
                Text("Speed: \(bt.speed, specifier: "%.01f") miles/h")
                Text("Trip: \(bt.totalDistance, specifier: "%.3f") km")
                Text("Raw: \(bt.rawHex)")
                    .font(.footnote)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text("Decoded: \(bt.lastTelemetry)")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
