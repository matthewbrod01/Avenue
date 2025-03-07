//
//  RouteViewController.swift
//  HomeDrive
//
//  Created by Kun Huang on 10/28/18.
//  Copyright © 2018 Matthew. All rights reserved.
//

import UIKit
import GoogleMaps

class RouteViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    var owner: [String: Any] = [:]
    var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lat = currentLocation?.latitude
        let long = currentLocation?.longitude
        
        let ownerLat = owner["latitude"] as? Double
        let ownerLong = owner["longitude"] as? Double
        let camera = GMSCameraPosition.camera(withLatitude: lat!, longitude: long!, zoom: 15)
        mapView.camera = camera
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        marker.title = "location1"
        marker.map = mapView
        
        let marker1 = GMSMarker()
        marker1.position = CLLocationCoordinate2D(latitude: ownerLat!, longitude: ownerLong!)
        marker1.title = "location2"
        marker1.map = mapView
        
        drawPath()
    }
    
    
    func drawPath() {
        let lat = currentLocation?.latitude
        let long = currentLocation?.longitude
        
        let ownerLat = owner["latitude"] as? Double
        let ownerLong = owner["longitude"] as? Double
        
        let origin = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        let destination = CLLocationCoordinate2D(latitude: ownerLat!, longitude: ownerLong!)
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&mode=driving&key=AIzaSyBc3hRaxJ4vFVlpL5ot153TyJg9jgVT0MM") else {
            return
        }
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                let routes = json["routes"] as! NSArray
                
                OperationQueue.main.addOperation {
                    for route in routes {
                        let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                        let points = routeOverviewPolyline.object(forKey: "points")
                        let path = GMSPath.init(fromEncodedPath: points! as! String)
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeWidth = 3
                        polyline.strokeColor = UIColor.red
                        
                        let bounds = GMSCoordinateBounds(path: path!)
                        self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                        
                        polyline.map = self.mapView
                        break
                    }
                }
                
            }
            
        }
        task.resume()
    }
    
}
