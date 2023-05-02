//
//  MainView.swift
//  ISSTrackerDemoSwiftUI
//
//  Created by Donald Angelillo on 5/2/23.
//

import SwiftUI
import MapKit

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    @State var locations: [AnnotationModel] = []
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 50.0, longitudeDelta: 50.0))

    var body: some View {
        VStack(spacing: 0) {
            Map(coordinateRegion: $mapRegion, annotationItems: locations) { location in
                // Yes this generates endless purple warnings but this is a known Apple bug.
                // See https://developer.apple.com/forums/thread/718697
                MapAnnotation(coordinate: location.coordinate) {
                    Image("iss")
                }
            }
            Text("Current ISS Location: \(viewModel.currentISSPositionName ?? "")")
                .foregroundColor(Color(uiColor: Colors.nasaBlue))
                .frame(height: 50)
        }
        .onChange(of: viewModel.currentISSPosition) { _ in
            if let currentISSPosition = viewModel.currentISSPosition {
                withAnimation {
                    let coordinate = currentISSPosition.coordinate

                    self.mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 50.0, longitudeDelta: 50.0))
                    self.locations = [AnnotationModel(name: "Current ISS Location", coordinate: currentISSPosition.coordinate)]
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}

struct AnnotationModel: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
