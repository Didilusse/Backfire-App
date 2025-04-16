//
//  ContentView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isOnboardingComplete") var isOnboardingComplete = false
    @AppStorage("lastConnectedDevice") var lastConnectedDeviceID: String?
    
    var body: some View {
        NavigationStack {
            Group {
                if isOnboardingComplete {
                    MainTabView()
                        .environmentObject(BluetoothManager.shared)
                        .onAppear {
                            attemptReconnectToSavedDevice()
                        }
                } else {
                    OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                        .environmentObject(BluetoothManager.shared)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func attemptReconnectToSavedDevice() {
        guard let deviceID = lastConnectedDeviceID,
              let uuid = UUID(uuidString: deviceID) else { return }
        
        BluetoothManager.shared.reconnectToSavedDevice(uuid: uuid)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BluetoothManager.shared)
    }
}
