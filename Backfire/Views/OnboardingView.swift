//
//  OnboardingView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/15/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Welcome
            VStack(spacing: 20) {
                Image(systemName: "figure.skateboarding")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Welcome to Zealot Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Connect your Backfire Zealot board to get real-time telemetry and riding statistics.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Get Started") {
                    currentPage = 1
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .tag(0)
            
            // Page 2: Bluetooth Permissions
            VStack(spacing: 20) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Bluetooth Connection")
                    .font(.title)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 10) {
                    Label("Enable Bluetooth in Settings", systemImage: "1.circle")
                    Label("Select your board from the list", systemImage: "2.circle")
                    Label("Start riding with live stats", systemImage: "3.circle")
                }
                .padding()
                
                Button("Continue") {
                    currentPage = 2
                }
                .buttonStyle(.borderedProminent)
            }
            .tag(1)
            
            // Page 3: Device Selection
            DeviceConnectionView(isOnboardingComplete: $isOnboardingComplete)
                .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
        .environmentObject(BluetoothManager.shared)
}
