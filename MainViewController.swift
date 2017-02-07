//
//  MainViewController.swift
//  OpenHack
//
//  Created by Rahul Tomar on 07/02/2017.
//  Copyright © 2017 TMFAction Week. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MainViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    let regionRadius: CLLocationDistance = 50000
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func addAnnotations(coords: [CLLocation]){
        for coord in coords{
            let CLLCoordType = CLLocationCoordinate2D(latitude: coord.coordinate.latitude,
                                                      longitude: coord.coordinate.longitude);
            let anno = MKPointAnnotation();
            anno.coordinate = CLLCoordType;
            anno.title = coord.description
            mapView.addAnnotation(anno);
        }
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        let latestLocation: CLLocation = locations[locations.count - 1]
        
        let urlPath = "http://spatial.cml.opendata.arcgis.com/datasets/eeaf308ed4d14b40b51117ec6a43a001_5.geojson"
        let url = NSURL(string: urlPath)
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if ((error) != nil) {
                print("Error")
            } else {
                // process json
                let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                let arr = jsonResult["features"] as! NSArray
                var nearest : CLLocation!
                var locArr : [CLLocation] = []
                for var i in 0..<arr.count{
                    let lon = (((((arr[i] as! NSDictionary)["geometry"]) as! NSDictionary)["coordinates"]) as! NSArray)[0] as! Double
                    let lat = (((((arr[i] as! NSDictionary)["geometry"]) as! NSDictionary)["coordinates"]) as! NSArray)[1] as! Double
                    let currentLocation: CLLocation = CLLocation(latitude: lat, longitude: lon)
                    locArr.append(currentLocation)
                    
                    if i == 0 {
                        nearest = currentLocation
                    }
                    else{
                        let distanceBetween1: CLLocationDistance =
                            nearest.distance(from: self.startLocation)
                        let distanceBetween2: CLLocationDistance =
                            currentLocation.distance(from: self.startLocation)
                        if distanceBetween1 > distanceBetween2 {
                            nearest = currentLocation
                        }
                    }
                }
                self.addAnnotations(coords: locArr)
                
                self.data_request(nearest: nearest)
            }
        })
        task.resume()
        centerMapOnLocation(location: latestLocation)
        if startLocation == nil {
            startLocation = latestLocation
        }
        let distanceBetween: CLLocationDistance =
            latestLocation.distance(from: startLocation)
        print(startLocation.description)
        print(String(format: "%.2f", distanceBetween))
    }
    
    func data_request(nearest: CLLocation)
    {
        let url:NSURL = NSURL(string: "http://ecommapi.huaweiapi.com/sms/batchSendSms/v1")!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        
        let requestid:UInt32 = arc4random_uniform(100)
        let requestidStr:String = String(requestid)
        request.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("WSSE realm=\"SDP\",profile=\"UsernameToken\",type=\"Appkey\"", forHTTPHeaderField: "Authorization")
        request.addValue("UsernameToken Username=\"a87d096db2af4d98b20d9c9fa0fc11df\",PasswordDigest=\"Ddl6mr8ioZYdw5CJBDGUOcn3/tkwbdrUk+WR78NlSUc=\",Nonce=\"5m8nh2klt9\",Created=\"2017-02-04T07:53:40Z\"", forHTTPHeaderField: "X-WSSE")
        request.addValue(requestidStr, forHTTPHeaderField: "Request-Id")
        request.addValue("100", forHTTPHeaderField: "Version")
        
        
        
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = "to=15850582938&body=【华为开发者社区】hello%20world"
        //let paramString = "to=00385992202962&body=hello%20world"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString ?? "Data")
            
        }
        
        task.resume()
        
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
