//
//  MainTabView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/16/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(BluetoothManager.shared)
                .tabItem {
                    Label("Dashboard", systemImage: "gauge")
                }
            RideHistoryView()
                .environmentObject(BluetoothManager.shared)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            SettingsView()
                .environmentObject(BluetoothManager.shared)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(BluetoothManager.shared)
}
