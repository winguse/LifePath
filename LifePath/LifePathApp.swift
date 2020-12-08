//
//  LifePathApp.swift
//  LifePath
//
//  Created by Yingyu Cheng on 12/8/20.
//

import SwiftUI

@main
struct LifePathApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
