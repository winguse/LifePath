//
//  ContentView.swift
//  LifePath
//
//  Created by Yingyu Cheng on 12/8/20.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @EnvironmentObject var store: LifePathStore

    var body: some View {
        MapView(locations: $store.locations)
            .edgesIgnoringSafeArea(.all)
            .onAppear(perform: fetch)
    }

    private func fetch() {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
            store.fetch24HLocations()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(LifePathStore())
        }
    }
}
