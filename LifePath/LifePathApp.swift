//
//  LifePathApp.swift
//  LifePath
//
//  Created by Yingyu Cheng on 12/8/20.
//

import SwiftUI
import CoreLocation
import CoreData

enum MonitorState {
    case Hight
    case Low
    case Pause
}

class AppDelegate: NSObject, UIApplicationDelegate, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private var onHighAccuateMonitor = false
    private var lastLocation: CLLocation? = nil


    func startLocationService() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        // locationManager.activityType = .otherNavigation
        locationManager.requestAlwaysAuthorization()
        startHighAccuateMonitor()
    }

    private func startHighAccuateMonitor() {
        onHighAccuateMonitor = true
        locationManager.stopMonitoringSignificantLocationChanges()

        let defaults = UserDefaults.standard
        if defaults.string(forKey: "accuracy") == "best" {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = defaults.double(forKey: "accuracy")
        }

        print("start high accuate monitor")
        // high accuate
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startUpdatingLocation()
    }

    private func startLowAccuateMonitor() {
        onHighAccuateMonitor = false
        print("start low accuate monitor")
        locationManager.stopUpdatingLocation()
        // low accuate
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        startLowAccuateMonitor()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !onHighAccuateMonitor {
            startHighAccuateMonitor()
        }
        if let current = locations.last {
            if (lastLocation == nil || (current.distance(from: lastLocation!) >= current.horizontalAccuracy + lastLocation!.horizontalAccuracy && current.timestamp.addingTimeInterval(10) >= lastLocation!.timestamp)) {
                lastLocation = current
                PersistenceController.shared.saveLocation(current)
            }
        }
    }


    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        startLocationService()
        return true
    }
}

@main
struct LifePathApp: App {
    let persistenceController = PersistenceController.shared

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LifePathStore())
        }
    }
}
