import Foundation
import CoreBluetooth
import SwiftUI
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    public var targetPeripheral: CBPeripheral?
    
    private var notifyCharacteristic: CBCharacteristic?
    
    @AppStorage("showSpeedInMPH") var showSpeedInMPH = true
    @AppStorage("wheelDiameter") var wheelDiameter = 105.0 {
        didSet {
            // Recalculate any wheel-dependent values
            refreshCalculations()
        }
    }
    
    @Published var voltage: Double = 0
    @Published var battery: Int = 0
    @Published var gear: String = ""
    @Published var rideDistance: Double = 0
    @Published var speed: Double = 0
    @Published var speedMPH: Double = 0
    @Published var totalDistance: Double = 0
    @Published var rawHex: String = ""
    
    private var lastTime: TimeInterval?
    private var motorPoles = 28
    private var wheelDiameterMM = 105.0
    @Published var discoveredDevices: [CBPeripheral] = []
    
    @Published var speedKmh: Double = 0
    @Published var rideDistanceKm: Double = 0
    @Published var totalDistanceKm: Double = 0
    
    var displayedSpeed: Double {
        showSpeedInMPH ? speedKmh * 0.621371 : speedKmh
    }
    
    var displayedDistanceUnit: String {
        showSpeedInMPH ? "mi" : "km"
    }
    
    var displayedSpeedUnit: String {
        showSpeedInMPH ? "mph" : "km/h"
    }
    
    static let shared = BluetoothManager()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil)
            if let uuidString = UserDefaults.standard.string(forKey: "lastConnectedDevice"),
               let uuid = UUID(uuidString: uuidString) {
                reconnectToSavedDevice(uuid: uuid)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    func disconnectCurrentBoard() {
        guard let peripheral = targetPeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
        targetPeripheral = nil
    }
    
    func forgetCurrentBoard() {
        UserDefaults.standard.removeObject(forKey: "lastConnectedDevice")
        disconnectCurrentBoard()
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for char in service.characteristics ?? [] {
            if char.properties.contains(.notify) {
                notifyCharacteristic = char
                peripheral.setNotifyValue(true, for: char)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        parseData(data)
    }
    
    func reconnectToSavedDevice(uuid: UUID) {
        if let peripheral = retrievePeripheral(with: uuid) {
            connectToDevice(peripheral)
        }
    }
    
    private func retrievePeripheral(with uuid: UUID) -> CBPeripheral? {
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [uuid]).first else {
            return nil
        }
        peripheral.delegate = self
        return peripheral
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        targetPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral)
        
        // Save connected device ID
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: "lastConnectedDevice")
    }
    
    func startScan() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.centralManager.stopScan()
        }
    }
    
    func parseData(_ data: Data) {
        self.rawHex = data.map { String(format: "%02X", $0) }.joined()
        guard data.count >= 20, data[0] == 0xAC else { return }
        
        // 1. Voltage (Bytes 1-2 Big-Endian)
        let voltageRaw = UInt16(data[2]) << 8 | UInt16(data[1])
        let voltageVal = Double(voltageRaw) / 100.0 // 64.0V ✅
        
        // 2. Battery (Byte 5)
        let batteryPct = Int(data[5]) // 0x37 = 55% ✅
        
        // 3. Odometer (Bytes 6-9 Big-Endian → Meters to Miles)
        let totalDistanceRaw = UInt32(data[6]) << 24 |
        UInt32(data[7]) << 16 |
        UInt32(data[8]) << 8 |
        UInt32(data[9])
        
        let totalMileageRaw = (UInt32(data[18]) << 16) | (UInt32(data[19]) << 8)
        let totalMileageKm = Double(totalMileageRaw) / 10.0
        let totalMileageMi = totalMileageKm * 0.621371
        
        
        let rawGear = Int(data[4])
        switch rawGear {
        case 1: gear = "Eco" // Eco
        case 2: gear = "Sport" // Sport
        case 3: gear = "Turbo"// Turbo
        default: gear = "Achievement How did we get here?" // Unknown
        } // 4. Gear (Byte 4 - Mode/Eco/Sport/etc.)
        
        
        let rideMileageRaw = UInt16(data[16]) << 8 | UInt16(data[17])
        let rideMileage = Double(rideMileageRaw) / 10.0
        let rideMileageMiles = rideMileage * 0.621371
        
        // Use the time difference to calculate speed
        let speedMPH = Double(totalDistanceRaw)/100000000
        
        let speedValue1 = (UInt16(data[6]) << 8) | UInt16(data[7])
        let speedValue2 = (UInt16(data[8]) << 8) | UInt16(data[9])
        self.speedKmh = Double(max(speedValue1, speedValue2)) / 100.0
        let speedMP = speedKmh * 0.621371
        print(speedMP)
        
        //calculated distance
        var distanceMi = self.totalDistance
        
        if speedMPH > 0.5, let last = lastTime {
            let now = Date().timeIntervalSince1970
            let dt = now - last  // Time in seconds
            distanceMi += speedMPH * (dt / 3600.0)  // Distance = speed * time (in miles)
            self.lastTime = now
        } else {
            self.lastTime = Date().timeIntervalSince1970  // Reset if not moving
        }
        
        // Update UI with calculated speed and total distance
        self.voltage = voltageVal
        self.battery = batteryPct
        self.gear = gear
        self.speed = speedMPH  // Set speed in mph
        self.totalDistance = totalMileageMi  // Update total distance in miles
        self.rideDistance = rideMileageMiles
    }
    
    private func refreshCalculations() {
        // Recalculate any values dependent on settings
        objectWillChange.send()
    }
    
}
