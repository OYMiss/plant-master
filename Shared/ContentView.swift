//
//  ContentView.swift
//  Shared
//
//  Created by 杨崇卓 on 22/2/2021.
//

import SwiftUI
import CoreData

extension View {
    func visiableWhen(_ visable: Bool) -> some View {
        if visable {
            return AnyView(self)
        } else {
            return AnyView(self.hidden())
        }
    }
    
    func existWhen(_ none: Bool) -> some View {
        if none {
            return AnyView(self)
        } else {
            return AnyView(EmptyView())
        }
    }
}

let SPRING: Int64 = 1
let SUMMER: Int64 = 2
let AUTUMN: Int64 = 4
let WINTER: Int64 = 8


func toString(i: Int64) -> String {
    return i > 0 ? "+" + String(i) : String(i)
}

func toString(i: Int) -> String {
    return i > 0 ? "+" + String(i) : String(i)
}

func getOjbectContext() -> NSManagedObjectContext {
    return PersistenceController.shared.container.viewContext
}

struct CustomSteper: View {
    // CoreData
    var viewContext: NSManagedObjectContext
    
    // Binding
    @Binding var record: Record
    
    // Feedback
    @State private var impactFeedback = UIImpactFeedbackGenerator()

    var body: some View {
        HStack {
            Image(systemName: "minus.circle").foregroundColor(record.count == 0 ? .gray : .blue)
                .onTapGesture {
                    if (record.count > 0) {
                        record.count -= 1
                        do {
                            try viewContext.save()
                            impactFeedback.impactOccurred()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
            Text("\(record.count)").frame(width: 32)
            Image(systemName: "plus.circle").foregroundColor(record.count == 12 ? .gray : .blue)
                .onTapGesture {
                    if (record.count < 12) {
                        record.count += 1
                        do {
                            try viewContext.save()
                            impactFeedback.impactOccurred()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
        }
    }
}

struct SeasonIndicator: View {
    let season: Int64
    
    var body: some View {
        HStack(spacing: 0) {
            Text(season & SPRING == 0 ? "○" : "●")
                .foregroundColor(season & SPRING == 0 ? .gray : .green).font(.footnote)
            Text(season & SUMMER == 0 ? "○" : "●")
                .foregroundColor(season & SUMMER == 0 ? .gray : .red).font(.footnote)
            Text(season & AUTUMN == 0 ? "○" : "●")
                .foregroundColor(season & AUTUMN == 0 ? .gray : .yellow).font(.footnote)
            Text(season & WINTER == 0 ? "○" : "●")
                .foregroundColor(season & WINTER == 0 ? .gray : .blue).font(.footnote)
        }
    }
}

struct RecordView: View {
    // CoreData
    var viewContext: NSManagedObjectContext

    @Binding var record: Record
    var isLoved: Bool
    
    var body: some View {
        let seed = record.seed!

        VStack {
            HStack {
                Text(seed.name!).frame(width: 64, alignment: .leading)
                Image(systemName: "heart.slash").existWhen(!isLoved)
                Spacer()
                SeasonIndicator(season: seed.season)
            }.padding(.top, 8).padding(.bottom, 8)
            
            HStack {
                Text("养分:").font(.footnote).foregroundColor(.secondary)
                Text(toString(i: seed.growthFormula / (isLoved ? 1 : 2)))
                    .frame(width: 32).foregroundColor(.blue)
                Text(toString(i: seed.compost / (isLoved ? 1 : 2)))
                    .frame(width: 32).foregroundColor(.yellow)
                Text(toString(i: seed.mansure / (isLoved ? 1 : 2)))
                    .frame(width: 32).foregroundColor(.purple)
                Spacer()
                CustomSteper(viewContext: viewContext, record: $record)
//                    .environment(\.managedObjectContext, viewContext)
            }.padding(.bottom, 8)
        }
    }
}

struct SeedPicker: View {
    // CoreData
    let seeds: FetchedResults<Seed>
    
    // Feedback
    @State private var impactFeedback = UIImpactFeedbackGenerator()
    
    // PresentationMode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    // Binding
    @Binding var selection: Seed?

    var body: some View {
        List {
            ForEach(seeds) { item in
                Button(action: {
                    selection = item
                    impactFeedback.impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(item.name!).frame(width: 64, alignment: .leading)
                        SeasonIndicator(season: item.season)
                        Spacer()
                        Text(toString(i: item.growthFormula)).frame(width: 32).foregroundColor(.blue)
                        Text(toString(i: item.compost)).frame(width: 32).foregroundColor(.yellow)
                        Text(toString(i: item.mansure)).frame(width: 32).foregroundColor(.purple)
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .visiableWhen(selection == item)
                    }
                }
            }
        }.navigationTitle("选择作物种类")
    }
}

struct AddSeedView: View {
    // CoreData
    var viewContext: NSManagedObjectContext

    var seeds: FetchedResults<Seed>
//    @State var records: FetchedResults<Record>

    // Feedback
    @State private var notificationFeedback = UINotificationFeedbackGenerator()
    
    // PresentationMode
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    // Custom State
    @State private var selection: Seed? = nil
    @State private var countString: String = ""
    
    var body: some View {
        List {
            Section(header: Text("种类")) {
                HStack {
                    Text("数量")
                    Spacer()
                    TextField("输入数量", text: $countString)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                }
                
                NavigationLink(destination: SeedPicker(seeds: seeds, selection: $selection)) {
                    Text("种类")
                    Spacer()
                    Text(selection != nil ? selection!.name! : "").foregroundColor(.secondary)
                }
            }
            
        }
        .navigationTitle("添加作物")
        .listStyle(InsetGroupedListStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if (selection != nil) {
                        let newRecord = Record(context: viewContext)
                        newRecord.count = Int64(countString) ?? 0
                        newRecord.seed = selection
                        newRecord.id = UUID()
                        newRecord.timestamp = Date()
                        do {
                            try viewContext.save()
                            notificationFeedback.notificationOccurred(.success)
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("添加")
                })
            }
        }
        .navigationBarTitleDisplayMode(.automatic)

    }
}


struct SeasonIcon: View {
    // Feedback
    @State private var notificationFeedback = UINotificationFeedbackGenerator()
    @State private var impactFeedback = UIImpactFeedbackGenerator()
    
    // Binding
    @Binding var season: Int64
    
    let seasonCode: Int64
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        Image(systemName: iconName)
            .foregroundColor(season & seasonCode != 0 ? iconColor : .gray).font(.title)
            .onTapGesture {
                if (season == seasonCode) {
                    season = 0
                } else {
                    season = seasonCode
                }
                impactFeedback.impactOccurred()
            }
            .onLongPressGesture {
                season ^= seasonCode
                notificationFeedback.prepare()
                notificationFeedback.notificationOccurred(.success)
            }
            
    }
}

struct ContentView: View {
    // CoreData
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Seed.name, ascending: true)])
    private var seeds: FetchedResults<Seed>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.timestamp, ascending: true)],
        animation: .default)
    private var records: FetchedResults<Record>
    

    // Feedback
    @State private var notificationFeedback = UINotificationFeedbackGenerator()
    @State private var impactFeedback = UIImpactFeedbackGenerator()
    
    // EditMode
    @State private var editing:EditMode = EditMode.inactive

    // Custom State
    @State private var showNotLoved = false
    @State private var value: Int64 = 0
    @State private var season: Int64 = 0
    
    func bindRecords(index: Int) -> Binding<Record> {
        return Binding(
            get: {
                records[index]
            },
            set: {
                records[index].setValue($0.id, forKey: "id")
                records[index].setValue($0.count, forKey: "count")
                records[index].setValue($0.seed, forKey: "seed")
                records[index].setValue($0.timestamp, forKey: "timestamp")
            })
    }

    var body: some View {
        List {
            Section(header: Text("季节")) {
                GeometryReader { metrics in
                    HStack (spacing: 0) {
                        SeasonIcon(season: $season, seasonCode: SPRING, iconName: "leaf", iconColor: .green)
                            .frame(width: metrics.size.width * 0.25)
                        SeasonIcon(season: $season, seasonCode: SUMMER, iconName: "sun.max", iconColor: .red)
                            .frame(width: metrics.size.width * 0.25)
                        SeasonIcon(season: $season, seasonCode: AUTUMN, iconName: "wind", iconColor: .yellow)
                            .frame(width: metrics.size.width * 0.25)
                        SeasonIcon(season: $season, seasonCode: WINTER, iconName: "snow", iconColor: .blue)
                            .frame(width: metrics.size.width * 0.25)
                    }
                }
            }
            Section(header: Text("所种植物")) {
                ForEach(Array(zip(records.indices, records)), id: \.1.id) { i, record in
                    let isLoved = record.seed!.season & season >= season
                    RecordView(viewContext: viewContext, record: bindRecords(index: i), isLoved: isLoved)
//                        .environment(\.managedObjectContext, viewContext)
                        .existWhen(showNotLoved || isLoved)
                }
                .onDelete(perform: { indexSet in
                    indexSet.map { records[$0] }.forEach(viewContext.delete)
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                })

            }
            
            Section(header: Text("养分消耗统计")) {
                let growthFormulaCost = records.filter{ item in
                    showNotLoved || item.seed!.season & season >= season
                }.reduce(0, { result, record in
                    result + record.seed!.growthFormula * record.count / (record.seed!.season & season >= season ? 1 : 2)
                })

                let compostCost = records.filter{ item in
                    showNotLoved || item.seed!.season & season >= season
                }.reduce(0, { result, record in
                    result + record.seed!.compost * record.count * (record.seed!.season & season >= season ? 1 : 2)
                })

                let mansureCost = records.filter{ item in
                    showNotLoved || item.seed!.season & season >= season
                }.reduce(0, { result, record in
                    result + record.seed!.mansure * record.count * (record.seed!.season & season >= season ? 1 : 2)
                })

                if (season == 0) {
                    Text("选择季节来获取统计数据")
                } else {
                    HStack {
                        Text("统计项目")
                        Spacer()
                        Text("成长").frame(width: 48).foregroundColor(.blue)
                        Text("堆肥").frame(width: 48).foregroundColor(.yellow)
                        Text("肥料").frame(width: 48).foregroundColor(.purple)
                    }
                    HStack {
                        Text("每阶段消耗:")
                        Spacer()
                        Text(toString(i: growthFormulaCost)).frame(width: 48).foregroundColor(.blue)
                        Text(toString(i: compostCost)).frame(width: 48).foregroundColor(.yellow)
                        Text(toString(i: mansureCost)).frame(width: 48).foregroundColor(.purple)
                    }

                    HStack {
                        Text("全阶段消耗:")
                        Spacer()
                        Text(toString(i: growthFormulaCost * 4)).frame(width: 48).foregroundColor(.blue)
                        Text(toString(i: compostCost * 4)).frame(width: 48).foregroundColor(.yellow)
                        Text(toString(i: mansureCost * 4)).frame(width: 48).foregroundColor(.purple)
                    }
                }


            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack{
                    Image(systemName: showNotLoved ? "heart.slash": "heart")
                        .foregroundColor(.blue).font(.title2).existWhen(self.editing == .inactive)
                        .onTapGesture {
                            showNotLoved = !showNotLoved
                            impactFeedback.impactOccurred()
                        }
                    NavigationLink(destination:AddSeedView(viewContext: viewContext, seeds: seeds)
//                                    .environment(\.managedObjectContext, viewContext)
                    ) {
                        Image(systemName: "plus").foregroundColor(.blue).font(.title2).existWhen(self.editing == .inactive)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .onDisappear {
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
                .navigationTitle("Plant Master")
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        
        }
    }
}
