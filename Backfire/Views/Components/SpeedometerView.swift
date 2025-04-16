//
//  SpeedometerView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/15/25.
//

import SwiftUI

struct SpeedometerView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        VStack {
            Text("Speed")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(Color.blue)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(bluetoothManager.speed/40, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundColor(Color.blue)
                    .rotationEffect(Angle(degrees: -90))
                
                VStack {
                    Text("\(bluetoothManager.displayedSpeed, specifier: "%.1f")")
                        .font(.system(size: 42, weight: .bold))
                    
                    Text(bluetoothManager.displayedSpeedUnit)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 200, height: 200)
            .padding()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}
