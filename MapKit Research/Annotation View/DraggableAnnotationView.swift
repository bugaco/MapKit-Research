//
//  DraggableAnnotationView.swift
//  MapKit Research
//
//  Created by ZanyZephyr on 2022/3/29.
//

import UIKit
import MapKit

class DraggableAnnotationView: MKAnnotationView {

    weak var mapView: MKMapView?
    var panClosure: Closure?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        isDraggable = false
        frame = .init(x: 0, y: 0, width: 40, height: 40)
        backgroundColor = .clear
        
        // Add a circle layer
        let circlePath = UIBezierPath(arcCenter: center, radius: 8.5, startAngle: 0, endAngle: Double.pi * 2, clockwise: true)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        
        circleLayer.fillColor = UIColor.red.cgColor
        circleLayer.strokeColor = UIColor.init(red: 0.52, green: 0.52, blue: 0.52, alpha: 1).cgColor
        circleLayer.lineWidth = 2
        
        layer.addSublayer(circleLayer)
        
        /**
         pan gesture
         */
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(onPan(_:)))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        
        if let mapView = mapView {
            let point = sender.location(in: mapView)
            let coordinate = mapView.convert(point,toCoordinateFrom: mapView)
            if let pointAnnotation = annotation as? MKPointAnnotation {
                pointAnnotation.coordinate = coordinate
            }
        }

        print("pan")
        self.center = sender.location(in: sender.view?.superview)
        panClosure?()
    }
    

}
