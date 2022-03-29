//
//  Extensions.swift
//  MapKit Research
//
//  Created by ZanyZephyr on 2022/3/29.
//

import MapKit

extension MKMapView {
    var zoomLevel: Int {
            get {
                return Int(log2(360 * (Double(self.frame.size.width/256) / self.region.span.longitudeDelta)) + 1);
            }

            set (newZoomLevel){
                setCenterCoordinate(coordinate:self.centerCoordinate, zoomLevel: newZoomLevel, animated: false)
            }
        }

        private func setCenterCoordinate(coordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool) {
            let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 360 / pow(2, Double(zoomLevel)) * Double(self.frame.size.width) / 256)
            setRegion(MKCoordinateRegion(center: coordinate, span: span), animated: animated)
        }
}
