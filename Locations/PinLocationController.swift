//
//  FirstViewController.swift
//  Locations
//
//  Created by Anish on 31/03/20.
//  Copyright © 2020 Locations. All rights reserved.
//

import UIKit
import CoreLocation

class PinLocationController: UIViewController {
    
    fileprivate enum Location: Int, CaseIterable {
        case latitude = 0
        case longitude
        case address
        
        var title: String {
            return String(describing: self)
        }
    }
    
    fileprivate let tableCellIdentifier = "LocationCell"
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    @IBOutlet weak var locationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getLocation() {
        getLocationServiceAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    private func getLocationServiceAuthorization() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authorizationStatus == .denied || authorizationStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
    }
    
    private func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in settings", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "dismiss", style: .default, handler: nil)
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func stopLocationManager() {
        
    }
}

extension PinLocationController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Location.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellIdentifier, for: indexPath)
        if let location = location {
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = String(describing: location.coordinate.latitude)
            case 1:
                cell.textLabel?.text = String(describing: location.coordinate.longitude)
            default:
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Location(rawValue: section)?.title
    }
}

extension PinLocationController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error.localizedDescription)")
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdate \(newLocation)")
        location = newLocation
        locationTableView.reloadData()
    }
}
