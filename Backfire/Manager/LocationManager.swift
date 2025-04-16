//
//  LocationManager.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/16/25.
//


import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var locations: [CLLocationCoordinate2D] = []
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        // Only enable if you NEED background updates
        manager.allowsBackgroundLocationUpdates = false // Changed to false
        manager.pausesLocationUpdatesAutomatically = false
    }
    
    func startTracking() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func stopTracking() {
        manager.stopUpdatingLocation()
        locations.removeAll()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
        
        if BluetoothManager.shared.isRideActive {
            self.locations.append(location.coordinate)
            BluetoothManager.shared.currentRide?.locations.append(location.coordinate)
            
            // Update ride stats every 10 seconds
            if self.locations.count % 10 == 0 {
                BluetoothManager.shared.currentRide?.speedData.append(BluetoothManager.shared.displayedSpeed)
                BluetoothManager.shared.currentRide?.batteryLevels.append(BluetoothManager.shared.battery)
            }
        }
    }
}
