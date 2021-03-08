//
//  PlantMasterApp.swift
//  Shared
//
//  Created by 杨崇卓 on 22/2/2021.
//

import SwiftUI

@main
struct PlantMasterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .navigationTitle("Plant Master")
            }
        }
    }
}
