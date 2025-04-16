//
//  RideHistoryView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/16/25.
//

import SwiftUI

struct RideHistoryView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        List(bluetoothManager.rideHistory) { ride in
            NavigationLink(destination: RideDetailView(ride: ride)) {
                VStack(alignment: .leading) {
                    Text(ride.startTime.formatted(date: .numeric, time: .shortened))
                    Text("Duration: \(formattedDuration(ride.duration))")
                        .font(.subheadline)
                    Text("Max Speed: \(ride.maxSpeed, specifier: "%.1f") \(bluetoothManager.displayedSpeedUnit)")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Ride History")
        .onAppear {
            bluetoothManager.loadRideHistory()
        }
    }
    
    private func formattedDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}

#Preview {
    RideHistoryView()
}
