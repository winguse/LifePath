//
//  LifePathApp.swift
//  LifePath
//
//  Created by Yingyu Cheng on 12/8/20.
//

import SwiftUI
import CoreLocation
import CoreData
import OSLog

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
            Utils.sendNotification(title: "Monitor accuate changed", body: "High best")
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = defaults.double(forKey: "accuracy")
            Utils.sendNotification(title: "Monitor accuate changed", body: "High \(locationManager.distanceFilter)m")
        }

        Logger.background.notice("start high accuate monitor")
        // high accuate
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startUpdatingLocation()
    }

    private func startLowAccuateMonitor() {
        onHighAccuateMonitor = false
        Logger.background.notice("start low accuate monitor")
        Utils.sendNotification(title: "Monitor accuate changed", body: "Low")
        locationManager.stopUpdatingLocation()
        // low accuate
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        startLowAccuateMonitor()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.background.error("location manager error: \(error as NSObject)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !onHighAccuateMonitor {
            startHighAccuateMonitor()
        }
        if let current = locations.last {
            if (lastLocation == nil
                    || current.horizontalAccuracy < lastLocation!.horizontalAccuracy
                    || (current.timestamp >= lastLocation!.timestamp.addingTimeInterval(10)
                        && current.distance(from: lastLocation!) >= current.horizontalAccuracy + lastLocation!.horizontalAccuracy)
                ) {
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
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                Logger.background.error("request for notification error \(error as NSObject)")
            }
        }
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
