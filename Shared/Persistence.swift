//
//  Persistence.swift
//  plant-master
//
//  Created by 杨崇卓 on 5/3/2021.
//

import CoreData

struct SeedNaive: Identifiable {
    var id: Int64
    var name: String
    var growthFormula: Int64
    var compost: Int64
    var mansure: Int64
    var season: Int64
}

let seedsNaive = [
    SeedNaive(id: 0, name: "芦笋", growthFormula: 2, compost: -4, mansure: 2, season: SPRING | WINTER),
    SeedNaive(id: 1, name: "胡萝卜", growthFormula: -4, compost: 2, mansure: 2, season: SPRING | AUTUMN | WINTER),
    SeedNaive(id: 2, name: "玉米", growthFormula: 2, compost: -4, mansure: 2, season: SPRING | SUMMER | AUTUMN),
    SeedNaive(id: 3, name: "火龙果", growthFormula: 4, compost: 4, mansure: -8, season: SPRING | SUMMER),
    SeedNaive(id: 4, name: "榴莲", growthFormula: 4, compost: -8, mansure: 4, season: SPRING),
    SeedNaive(id: 5, name: "茄子", growthFormula: 2, compost: 2, mansure: -4, season: SPRING | AUTUMN),
    SeedNaive(id: 6, name: "大蒜", growthFormula: 4, compost: -8, mansure: 4, season: SPRING | SUMMER | AUTUMN | WINTER),
    SeedNaive(id: 7, name: "洋葱", growthFormula: -8, compost: 4, mansure: 4, season: SPRING | SUMMER | AUTUMN),
    SeedNaive(id: 8, name: "辣椒", growthFormula: 4, compost: 4, mansure: -8, season: SUMMER | AUTUMN),
    SeedNaive(id: 9, name: "石榴", growthFormula: -8, compost: 4, mansure: 4, season: SPRING | SUMMER),
    SeedNaive(id: 10, name: "土豆", growthFormula: 2, compost: 2, mansure: -4, season: SPRING | AUTUMN | WINTER),
    SeedNaive(id: 11, name: "南瓜", growthFormula: -4, compost: 2, mansure: 2, season: AUTUMN | WINTER),
    SeedNaive(id: 12, name: "番茄", growthFormula: -2, compost: -2, mansure: 4, season: SPRING | SUMMER | AUTUMN),
    SeedNaive(id: 13, name: "西瓜", growthFormula: 4, compost: -2, mansure: -2, season: SPRING | SUMMER)
]

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        

        // Seeds Records
        for i in 0..<3 {
            let s = Seed(context: viewContext)
            let r = Record(context: viewContext)

            let seed = seedsNaive[i]
            s.id = Int64(seed.id)
            s.name = seed.name
            s.growthFormula = Int64(seed.growthFormula)
            s.compost = Int64(seed.compost)
            s.mansure = Int64(seed.mansure)
            s.season = Int64(seed.season)
            
            r.seed = s
            r.id = UUID()
            r.count = Int64(i + 1)
            r.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
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
//        do {
//            if try container.viewContext.fetch(Seed.fetchRequest()).isEmpty {
//                for seed in seedsNaive {
//                    let s = Seed(context: container.viewContext)
//                    s.id = Int64(seed.id)
//                    s.name = seed.name
//                    s.growthFormula = Int64(seed.growthFormula)
//                    s.compost = Int64(seed.compost)
//                    s.mansure = Int64(seed.mansure)
//                    s.season = Int64(seed.season)
//                }
//                try container.viewContext.save()
//            }
//        } catch {
//
//        }
    }
}
