//
//  Persistence.swift
//  LifePath
//
//  Created by Yingyu Cheng on 12/8/20.
//

import CoreData
import OSLog

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
                Logger.background.critical("Error was found when create data store instance \(storeDescription), \(error), \(error.userInfo)")
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
            let nsError = error as NSError
            Logger.background.critical("Error found when trying to save location \(nsError), \(nsError.userInfo)")
        }
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
            return try ctx.fetch(fetchRequest)
        } catch {
            let nsError = error as NSError
            Logger.background.critical("Error found when trying to fetch locations \(nsError), \(nsError.userInfo)")
        }
        return [Location]()
    }
    
    func queryMinTimestamp() -> Date {
        let ctx = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(
            entityName: "Location"
        )
        request.resultType = NSFetchRequestResultType.dictionaryResultType
        let keypathExpression = NSExpression(forKeyPath: "timestamp")
        let maxExpression = NSExpression(forFunction: "min:", arguments: [keypathExpression])
        let key = "minTimestamp"
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = key
        expressionDescription.expression = maxExpression
        expressionDescription.expressionResultType = .dateAttributeType
        request.propertiesToFetch = [expressionDescription]
        do {
             if let result = try ctx.fetch(request) as? [[String: Date]],
                let dict = result.first,
                let minDate = dict[key] {
                Logger.background.debug("Find min timestamp \(minDate)")
                return minDate
             }
            Logger.background.warning("Cannot find min timestamp")
         } catch {
            let nsError = error as NSError
            Logger.background.critical("Error found when trying to fetch min timestamp \(nsError), \(nsError.userInfo)")
         }
        return Date.init(timeIntervalSince1970: 0)
    }
}
