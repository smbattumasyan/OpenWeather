//
//  OWViewController.swift
//  OpenWeather
//
//  Created by Smbat Tumasyan on 30.10.17.
//  Copyright © 2017 Smbat Tumasyan. All rights reserved.
//

import UIKit
import CoreLocation

class OWViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    var webService: WeatherServiceProtocol?
    var locationManager:CLLocationManager!
    var userLoc: (CLLocationDegrees, CLLocationDegrees)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webService = WeatherWebService()
        determineMyCurrentLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(OWViewController.currentWeather), name: Notification.Name("locationAvailable"), object: nil)
    }
}


extension OWViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = "hello "
        return cell
    }
   
}

extension OWViewController: CLLocationManagerDelegate {
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        self.userLoc = (userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        if self.userLoc != nil {
            NotificationCenter.default.post(name: Notification.Name("locationAvailable"), object: nil)
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}

extension OWViewController: WeatherServiceProtocol {
    @objc func currentWeather() {
        self.webService?.currentWeatherRequest!(withCoordinate: (self.userLoc?.0)!, lng: (self.userLoc?.1)!, completionHandler: { (data, response, error) in
            do {
                if let data = data {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    print("jsonn\(json!)")
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
        })
        NotificationCenter.default.removeObserver(self, name: Notification.Name("locationAvailable"), object: nil)
    }
}






