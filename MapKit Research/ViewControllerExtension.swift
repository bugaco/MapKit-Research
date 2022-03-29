//
//  ViewControllerExtension.swift
//  MapKit Research
//
//  Created by ZanyZephyr on 2022/3/29.
//

import Foundation
import MapKit
import SwiftUI

extension ViewController {
    
    func generateDefaultDraggablePoints() {
        
        /// 默认生成的多边形，是和 View 一样大的，适当缩小一点，方便操作
        let shrinkScale: CGFloat = 0.65
        
        var path = Path()
        
        let center = CGPoint(x: mapView.width / 2, y: mapView.height / 2 - 150)
        
        // start from directly upwards (as opposed to down or to the right)
        var currentAngle = -CGFloat.pi / 2
        
        // calculate how much we need to move with each star corner
        let angleAdjustment = .pi * 2 / CGFloat(pointCount)
        
        let startPoint = CGPoint(x: center.x * cos(currentAngle) * shrinkScale, y: center.y * sin(currentAngle) * shrinkScale)
        path.move(to: startPoint)
        
        // track the lowest point we draw to, so we can center later
        var bottomEdge: CGFloat = 0

        // loop over all our points/inner points
        for _ in 0..<pointCount  {
            // figure out the location of this point
            let sinAngle = sin(currentAngle)
            let cosAngle = cos(currentAngle)
            let bottom: CGFloat

            // store this Y position
            bottom = center.y * sinAngle * shrinkScale
            
            // …and add a line to there
            let point = CGPoint(x: center.x * cosAngle * shrinkScale, y: bottom)
            path.addLine(to: point)
            
            // if this new bottom point is our lowest, stash it away for later
            if bottom > bottomEdge {
                bottomEdge = bottom
            }

            // move on to the next corner
            currentAngle += angleAdjustment
        }
        
        // figure out how much unused space we have at the bottom of our drawing rectangle
        let unusedSpace = (mapView.height / 2 - bottomEdge) / 2

        // create and apply a transform that moves our path down by that amount, centering the shape vertically
        let transform = CGAffineTransform(translationX: center.x, y: center.y + unusedSpace)
        let pathResult = path.applying(transform)
        let cgPath = pathResult.cgPath
        var finalPoints = cgPath.getPathElementsPoints()
        finalPoints.removeFirst()
        print(finalPoints)
        
        var coordinates = [CLLocationCoordinate2D]()
        for point in finalPoints {
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            coordinates.append(coordinate)
        }
        addNewPolygon(with: coordinates)
        addPointAnnotation(coordinates)
    }
    
    func addPointAnnotation(_ coordinates: [CLLocationCoordinate2D]) {
        print("debug - 之前:\n", coordinates.description)
        // add point (annotation)
        for coordinate in coordinates {
            let point = MKPointAnnotation()
            point.coordinate = coordinate
            point.title = "Drag to fit shape"
            pointAnnotations.append(point)
        }
        mapView.addAnnotations(pointAnnotations)
    }
    
    
    /**
     将指定的经纬度排序，使之围成一个凸多边形，参考：
     https://gist.github.com/adunsmoor/e848356a57980ab9f822
     https://stackoverflow.com/questions/38344993/mkmapkit-draggable-annotation-and-drawing-polygons
     https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Convex_hull/Monotone_chain
     */
    func sortConvex(input: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {

        // X = longitude
        // Y = latitude

        // 2D cross product of OA and OB vectors, i.e. z-component of their 3D cross product.
        // Returns a positive value, if OAB makes a counter-clockwise turn,
        // negative for clockwise turn, and zero if the points are collinear.
        func cross(P: CLLocationCoordinate2D, _ A: CLLocationCoordinate2D, _ B: CLLocationCoordinate2D) -> Double {
            let part1 = (A.longitude - P.longitude) * (B.latitude - P.latitude)
            let part2 = (A.latitude - P.latitude) * (B.longitude - P.longitude)
            return part1 - part2;
        }
        
        // Sort points lexicographically
        let points: [CLLocationCoordinate2D] = input.sorted { a, b in
            a.longitude < b.longitude || a.longitude == b.longitude && a.longitude < b.longitude
        }
        
        // Build the lower hull
        var lower: [CLLocationCoordinate2D] = []
        
        for p in points {
            while lower.count >= 2 {
                let a = lower[lower.count - 2]
                let b = lower[lower.count - 1]
                if cross(P: p, a, b) > 0 { break }
                lower.removeLast()
            }
            lower.append(p)
        }

        // Build upper hull
        var upper: [CLLocationCoordinate2D] = []
        
        for p in points.lazy.reversed() {
            while upper.count >= 2 {
                let a = upper[upper.count - 2]
                let b = upper[upper.count - 1]
                if cross(P: p, a, b) > 0 { break }
                upper.removeLast()
            }
            upper.append(p)
        }

        // Last point of upper list is omitted because it is repeated at the
        // beginning of the lower list.
        upper.removeLast()

        // Concatenation of the lower and upper hulls gives the convex hull.
        return (upper + lower)
    }
}
