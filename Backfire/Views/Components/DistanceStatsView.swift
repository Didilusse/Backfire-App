//
//  DistanceStatsView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/15/25.
//
import SwiftUI

struct DistanceStatsView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    private func convertDistance(_ km: Double) -> Double {
        bluetoothManager.showSpeedInMPH ? km * 0.621371 : km
    }
    
    var body: some View {
        HStack {
            VStack {
                Text("Trip")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("\(convertDistance(bluetoothManager.rideDistanceKm), specifier: "%.1f") \(bluetoothManager.displayedDistanceUnit)")
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text("Total")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text("\(convertDistance(bluetoothManager.totalDistanceKm), specifier: "%.1f") \(bluetoothManager.displayedDistanceUnit)")
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}
