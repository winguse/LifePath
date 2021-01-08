//
//  LifePathStore.swift
//  LifePath
//
//  Created by Yingyu Cheng on 1/6/21.
//

import SwiftUI

class LifePathStore: ObservableObject {

    private let pc: PersistenceController

    init(pc: PersistenceController = PersistenceController.shared) {
        self.pc = pc
        fetch24HLocations()
    }

    @Published var locations = [Location]()

    func fetch24HLocations() {
        locations = pc.queryLocations(
            start: Date.init(timeIntervalSinceNow: 24 * -3600),
            end: Date.init(timeIntervalSinceNow: 0)
        )
    }
}
