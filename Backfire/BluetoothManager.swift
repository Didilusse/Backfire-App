import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    public var targetPeripheral: CBPeripheral?
    
    private let RXD_CHAR_UUID = CBUUID(string: "0000f1f2-0000-1000-8000-00805f9b34fb")
    private let TARGET_NAME = "HW_UG913120" // Your board's BLE name

    @Published var voltage: Double = 0
    @Published var battery: Int = 0
    @Published var speed: Double = 0
    @Published var speedMPH: Double = 0
    @Published var totalDistance: Double = 0
    @Published var rawHex: String = ""
    @Published var lastTelemetry: String = ""

    private var lastTime: TimeInterval?
    private var motorPoles = 28
    private var wheelDiameterMM = 105.0
    
    @Published var discoveredDevices: [CBPeripheral] = []

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil)
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

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for char in service.characteristics ?? [] {
            if char.uuid == RXD_CHAR_UUID {
                peripheral.setNotifyValue(true, for: char)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        parseData(data)
    }

    func parseData(_ data: Data) {
        self.rawHex = data.map { String(format: "%02X", $0) }.joined()
        guard data.count >= 20, data[0] == 0xAC else { return }

        // 1. Voltage (64.0V)
        let voltageRaw = UInt16(data[2]) << 8 | UInt16(data[1])
        let voltageVal = Double(voltageRaw) / 100.0
        
        // 2. Battery (Byte 5)
        let batteryPct = Int(data[5])
        
        // 3. TRUE Speed Indicator (Byte 17)
        let speedKmh = Double(data[17]) // Direct speed in km/h
        
        // 4. TRUE Odometer (Bytes 12-15 Little-Endian)
        let totalDistanceRaw = UInt32(data[12]) |
                             (UInt32(data[13]) << 8) |
                             (UInt32(data[14]) << 16) |
                             (UInt32(data[15]) << 24)
        let totalDistanceMiles = Double(totalDistanceRaw) / 1609.34
        
        // Update UI
        self.voltage = voltageVal
        self.battery = batteryPct
        self.speed = speedKmh
        self.speedMPH = speedKmh * 0.621371
        self.totalDistance = totalDistanceMiles
        
        self.lastTelemetry = String(format: "%.1fV | %d%% | %.1fmph | %.1fmi",
                                  voltageVal, batteryPct, speedMPH, totalDistanceMiles)
    }

    func connectToDevice(_ peripheral: CBPeripheral) {
        self.targetPeripheral = peripheral
        self.targetPeripheral?.delegate = self
        centralManager.connect(peripheral)
    }
}
