//
//  Persistence.swift
//  LifePath
//
//  Created by Yingyu Cheng on 12/8/20.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    private let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "LifePath")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }

    func saveLocation(_ clLocation: CLLocation) {
        let ctx = container.viewContext
        let newLocation = Location(context: ctx)
        newLocation.timestamp = clLocation.timestamp
        newLocation.altitude = clLocation.altitude
        newLocation.latitude = clLocation.coordinate.latitude
        newLocation.longitude = clLocation.coordinate.longitude
        newLocation.horizontalAccuracy = clLocation.horizontalAccuracy
        newLocation.verticalAccuracy = clLocation.verticalAccuracy
        newLocation.speed = clLocation.speed
        newLocation.speedAccuracy = clLocation.speedAccuracy
        do {
            try ctx.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        // print("saved \(newLocation.latitude), \(newLocation.lontitude)")
    }

    func queryLocations(start: Date, end: Date) -> [Location] {
        let ctx = container.viewContext
        let fetchRequest = NSFetchRequest<Location>(
            entityName: "Location"
        )
        fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                NSPredicate.init(format: "timestamp >= %@", start as NSDate),
                NSPredicate.init(format: "timestamp < %@", end as NSDate),
            ])
        do {
            var locations = try ctx.fetch(fetchRequest)
            var compactedCount = 1
            for index in 1..<locations.count {
                let pre = CLLocation(latitude: locations[compactedCount - 1].latitude, longitude: locations[compactedCount - 1].longitude)
                let cur = CLLocation(latitude: locations[index].latitude, longitude: locations[index].longitude)
                if (cur.distance(from: pre) > (locations[compactedCount - 1].horizontalAccuracy + locations[index].horizontalAccuracy)) {
                    locations[compactedCount] = locations[index]
                    compactedCount += 1
                }
            }
            locations.removeLast(locations.count - compactedCount)
            return locations
        } catch {
            // TODO error handling
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return [Location]()
    }
}
