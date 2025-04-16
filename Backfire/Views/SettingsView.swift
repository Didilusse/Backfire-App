import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @Environment(\.dismiss) var dismiss
    
    // App settings storage
    @AppStorage("showSpeedInMPH") var showSpeedInMPH = true
    @AppStorage("wheelDiameter") var wheelDiameter = 96.0
    @AppStorage("useDarkMode") var useDarkMode = false
    @State private var showForgetConfirmation = false
    
    var body: some View {
        Form {
            Section(header: Text("App Settings")) {
                Toggle("Show Speed in MPH", isOn: $showSpeedInMPH)
                Toggle("Dark Mode", isOn: $useDarkMode)
                
                Picker("Wheel Diameter", selection: $wheelDiameter) {
                    Text("96mm (Stock)").tag(96.0)
                    Text("105mm (Cloudwheels)").tag(105.0)
                    Text("120mm (Cloudwheels)").tag(120.0)
                    Text("150mm (AT)").tag(150.0)
                }
            }
            
            Section(header: Text("Current Board")) {
                if let peripheral = bluetoothManager.targetPeripheral {
                    HStack {
                        Text("Connected Board")
                        Spacer()
                        Text(peripheral.name ?? "Unknown Board")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Disconnect") {
                        bluetoothManager.disconnectCurrentBoard()
                    }
                    .foregroundColor(.orange)
                } else {
                    Text("No board connected")
                        .foregroundColor(.secondary)
                }
            }
            Section(header: Text("Danger Zone")) {
                Button("Forget This Board") {
                    showForgetConfirmation = true
                }
                .foregroundColor(.red)
                .disabled(bluetoothManager.targetPeripheral == nil)
                .alert("Are you sure you want to forget this board?", isPresented: $showForgetConfirmation) {
                    Button("Forget", role: .destructive) {
                        bluetoothManager.forgetCurrentBoard()
                        dismiss()
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(useDarkMode ? .dark : .light)
    }
    
}
#Preview {
    SettingsView()
        .environmentObject(BluetoothManager.shared)
}
