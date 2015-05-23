//
//  ViewController.swift
//  Memorable-Places
//
//  Created by Lala Vaishno De on 5/22/15.
//  Copyright (c) 2015 Lala Vaishno De. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var map: MKMapView!
    
    var manager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        manager = CLLocationManager();
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if activePlace == -1 {
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        }
        else {
            
            let latitude = NSString(string: places[activePlace]["lat"]!).doubleValue
            let longitude = NSString(string: places[activePlace]["lon"]!).doubleValue
        
            var letDelta:CLLocationDegrees = 0.01
            var lonDelta:CLLocationDegrees = 0.01
            var span:MKCoordinateSpan = MKCoordinateSpanMake(letDelta, lonDelta)
            var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            self.map.setRegion(region, animated: true)

            var annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = places[activePlace]["name"]
            self.map.addAnnotation(annotation)
            
            
            var uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
            uilpgr.minimumPressDuration = 2
            map.addGestureRecognizer(uilpgr)
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        println(locations)
        
        var userLocation:CLLocation = locations[0] as CLLocation
        var latitude = userLocation.coordinate.latitude
        var longitude = userLocation.coordinate.longitude
        var letDelta:CLLocationDegrees = 0.001
        var lonDelta:CLLocationDegrees = 0.001
        var span:MKCoordinateSpan = MKCoordinateSpanMake(letDelta, lonDelta)
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        self.map.setRegion(region, animated: true)
        //self.map.showsUserLocation = true

        
        var uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        uilpgr.minimumPressDuration = 2
        map.addGestureRecognizer(uilpgr)
        
    }
    
    func action(gestureRecognizer: UIGestureRecognizer) {
        
        println("Gesture Recognized")
        
        //ensure that only 1 long press runs once
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
        
            var touchPoint = gestureRecognizer.locationInView(self.map)
            var newCoordinate = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            
            var location:CLLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            var address = ""
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                //println(location)
                
                if error != nil {
                    println("Reverse geocoder failed with error" + error.localizedDescription)
                    return
                }
                
                if placemarks.count > 0 {
                    let pm = placemarks[0] as CLPlacemark
    
                    var subThoroughfare = pm.subThoroughfare ?? ""
                    var thoroughfare = pm.thoroughfare ?? ""
                    var gayfare = subThoroughfare + " " + thoroughfare
                    var locality = pm.locality ?? ""
                    var sublocality = pm.subLocality ?? ""
                    var gaylocality = sublocality + " " + locality
                    address = gayfare + " " + gaylocality
                }
                else {
                    println("Problem with the data received from geocoder")
                }
            

            
                if (address == "" || address == " ") {
                    address = "Added \(NSDate())"
                }
            
                places.append(["name" : address, "lat" : "\(newCoordinate.latitude)", "lon" : "\(newCoordinate.longitude)"])
            
                var annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                annotation.title = address
                self.map.addAnnotation(annotation)
            
            })
          
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

