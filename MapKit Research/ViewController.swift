//
//  ViewController.swift
//  MapKit Research
//
//  Created by ZanyZephyr on 2022/3/28.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    var pointCount = 5
    var pointAnnotations = [MKPointAnnotation]()
    var annotationViews = [MKAnnotationView]()
    let mapView = MKMapView.init()
    lazy var initMapView: () = {
        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.delegate = self
        mapView.register(DraggableAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(DraggableAnnotationView.self))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureHierarchy()
    }

}

extension ViewController {
    
    func configureHierarchy() {
        _ = initMapView
        self.mapView.zoomLevel = 13
        generateDefaultDraggablePoints()
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("DidFinishLoadingMap")
        
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        print("DidFinishRenderingMap")
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        print("DidChangeVisibleRegion")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
        
        let zoomWidth = mapView.visibleMapRect.size.width
            let zoomFactor = Int(log2(zoomWidth)) - 9
            print("...REGION DID CHANGE: ZOOM FACTOR \(zoomFactor)")
        let level = mapView.zoomLevel
        print("my zoom level:", level)
        let intLevel = lroundf(Float(level))
        print("四舍五入后的 int zoom level:", intLevel)
        /**
         四舍五入后更合理一些这个
         zoom level: 范围：1～20
         */
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {
            return nil
        }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(DraggableAnnotationView.self), for: annotation) as! DraggableAnnotationView
        annotationView.mapView = mapView
        annotationView.panClosure = { [weak self] in
            self?.handlePointOnDragging()
        }
        if !annotationViews.contains(annotationView) {
            annotationViews.append(annotationView)
        }
        print("annotationViews.count", annotationViews.count)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polygonView = MKPolygonRenderer(overlay: overlay)
        let fillColor = UIColor.init(displayP3Red: 0.06, green: 0.57, blue: 0.94, alpha: 0.4)
        let strokeColor = UIColor.init(displayP3Red: 0.12, green: 0.57, blue: 0.98, alpha: 1)
        polygonView.fillColor = fillColor
        
        return polygonView
        
    }
}

extension ViewController {
    
    func handlePointOnDragging() {
        
        // 这样随着拖动手势不停的删除、添加，会伴随着 polygon 闪烁
        removeExistedPolygon()
        addNewPolygonByAnnotationViews()
         
    }
    
    func removeExistedPolygon() {
        let overlays = mapView.overlays
        let polygonOverlays = overlays.filter( {$0 is MKPolygon} )
        print("polygonOverlays count:", polygonOverlays.count)
        mapView.removeOverlays(polygonOverlays)
    }
    
    func addNewPolygon(with coordinates: [CLLocationCoordinate2D]) {
        let polygon = MKPolygon.init(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polygon)
    }
    
    func addNewPolygonByAnnotationViews() {
        print("annotation view's count:", annotationViews.count)
        let coordinates = getCoordinatesFromAnnotationViews()
        print("coordinates count:", coordinates.count)
        addNewPolygon(with: coordinates)
    }
    
    private func getCoordinatesFromAnnotationViews() -> [CLLocationCoordinate2D] {
        var coordinates =  mapView.annotations.map({ $0.coordinate })
        coordinates = sortConvex(input: coordinates)
        return coordinates
    }
   
}
