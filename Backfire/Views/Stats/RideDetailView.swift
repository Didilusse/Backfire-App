//
//  RideDetailView.swift
//  Backfire
//
//  Created by Adil Rahmani on 4/16/25.
//

// RideDetailView.swift
import SwiftUI
import MapKit

struct RideDetailView: View {
    let ride: Ride
    @State private var region = MKCoordinateRegion()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Stats Section
                VStack(alignment: .leading) {
                    Text("Ride Details")
                        .font(.title2)
                    
                    DetailRow(title: "Distance", value: String(format: "%.2f mi", ride.distance))
                    DetailRow(title: "Duration", value: formattedDuration(ride.duration))
                    DetailRow(title: "Max Speed", value: String(format: "%.1f mph", ride.maxSpeed))
                    DetailRow(title: "Avg Speed", value: String(format: "%.1f mph", ride.averageSpeed))
                    DetailRow(
                        title: "Battery Start/End",
                        value: "\(ride.batteryLevels.first ?? 0)% → \(ride.batteryLevels.last ?? 0)%"
                    )
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                // Map View
                MapView(ride: ride)
                    .frame(height: 300)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle(ride.startTime.formatted(date: .abbreviated, time: .shortened))
    }
    
    private func formattedDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0:00"
    }
}

struct MapView: UIViewRepresentable {
    let ride: Ride
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        addPolyline(to: mapView)
        setRegion(for: mapView)
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update the view if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func addPolyline(to mapView: MKMapView) {
        let polyline = MKPolyline(coordinates: ride.locations, count: ride.locations.count)
        mapView.addOverlay(polyline)
    }
    
    private func setRegion(for mapView: MKMapView) {
        guard !ride.locations.isEmpty else { return }
        
        let latitudes = ride.locations.map { $0.latitude }
        let longitudes = ride.locations.map { $0.longitude }
        
        let center = CLLocationCoordinate2D(
            latitude: (latitudes.min()! + latitudes.max()!) / 2,
            longitude: (longitudes.min()! + longitudes.max()!) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (latitudes.max()! - latitudes.min()!) * 1.5,
            longitudeDelta: (longitudes.max()! - longitudes.min()!) * 1.5
        )
        
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
