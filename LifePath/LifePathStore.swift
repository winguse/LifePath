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
        minTimestatmp = pc.queryMinTimestamp()
    }

    @Published var minTimestatmp: Date = Date.init(timeIntervalSince1970: 0)
    @Published var locations = [Location]()

    func fetchLocations(start: Date, end: Date) {
        let newLocations = pc.queryLocations(start: start, end: end)
        if locations.last != newLocations.last || locations.first != newLocations.first {
            locations = newLocations
        }
    }
}
