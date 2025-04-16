//
//  Ride.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/16/25.
//
import Foundation
import MapKit

extension [CLLocationCoordinate2D] {
    var distanceInMeters: CLLocationDistance {
        guard count > 1 else { return 0 }
        
        var totalDistance: CLLocationDistance = 0
        var previousLocation: CLLocation?
        
        for coordinate in self {
            let currentLocation = CLLocation(latitude: coordinate.latitude,
                                            longitude: coordinate.longitude)
            if let previous = previousLocation {
                totalDistance += currentLocation.distance(from: previous)
            }
            previousLocation = currentLocation
        }
        return totalDistance
    }
}


struct Ride: Identifiable, Codable {
    var id: UUID  // Changed to var
    let startTime: Date
    var endTime: Date?
    var locations: [CLLocationCoordinate2D]
    var speedData: [Double]
    var batteryLevels: [Int]
    
    // Initializer for new rides
    init(startTime: Date, locations: [CLLocationCoordinate2D], speedData: [Double], batteryLevels: [Int]) {
        self.id = UUID()
        self.startTime = startTime
        self.locations = locations
        self.speedData = speedData
        self.batteryLevels = batteryLevels
    }
    
    // Initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date?.self, forKey: .endTime)
        speedData = try container.decode([Double].self, forKey: .speedData)
        batteryLevels = try container.decode([Int].self, forKey: .batteryLevels)
        
        let locationData = try container.decode([Data].self, forKey: .locations)
        locations = locationData.map { data in
            var coordinate = CLLocationCoordinate2D()
            _ = withUnsafeMutableBytes(of: &coordinate) { data.copyBytes(to: $0) }
            return coordinate
        }
    }
    
    
    var duration: TimeInterval {
        (endTime ?? Date()).timeIntervalSince(startTime)
    }
    
    var maxSpeed: Double {
        speedData.max() ?? 0
    }
    
    var averageSpeed: Double {
        speedData.isEmpty ? 0 : speedData.reduce(0, +) / Double(speedData.count)
    }
    
    var distance: Double {
        locations.distanceInMeters * 0.000621371 // Convert meters to miles
    }
    
    enum CodingKeys: String, CodingKey {
        case id, startTime, endTime, locations, speedData, batteryLevels
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(speedData, forKey: .speedData)
        try container.encode(batteryLevels, forKey: .batteryLevels)
        
        let locationData = locations.map { coordinate in
            var copy = coordinate
            return Data(bytes: &copy, count: MemoryLayout<CLLocationCoordinate2D>.size)
        }
        try container.encode(locationData, forKey: .locations)
    }
}
