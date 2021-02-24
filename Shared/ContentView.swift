//
//  ContentView.swift
//  Shared
//
//  Created by 杨崇卓 on 22/2/2021.
//

import SwiftUI

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


struct Seed: Identifiable {
    var id: Int
    var name: String
    var growthFormula: Int
    var compost: Int
    var mansure: Int
    var season: Int
}

struct Record: Identifiable {
    var id = UUID()
    var seed: Seed
    var count: Int
}

let SPRING = 1
let SUMMER = 2
let AUTUMN = 4
let WINTER = 8

let seeds = [
    Seed(id: 0, name: "芦荟", growthFormula: 2, compost: -4, mansure: 2, season: SPRING | WINTER),
    Seed(id: 1, name: "胡萝卜", growthFormula: -4, compost: 2, mansure: 2, season: SPRING | AUTUMN | WINTER),
    Seed(id: 2, name: "玉米", growthFormula: 2, compost: -4, mansure: 2, season: SPRING | SUMMER | AUTUMN),
    Seed(id: 3, name: "火龙果", growthFormula: 4, compost: 4, mansure: -8, season: SPRING | SUMMER),
    Seed(id: 4, name: "榴莲", growthFormula: 4, compost: -8, mansure: 4, season: SPRING),
    Seed(id: 5, name: "茄子", growthFormula: 2, compost: 2, mansure: -4, season: SPRING | AUTUMN),
    Seed(id: 6, name: "大蒜", growthFormula: 4, compost: -8, mansure: 4, season: SPRING | SUMMER | AUTUMN | WINTER),
    Seed(id: 7, name: "洋葱", growthFormula: -8, compost: 4, mansure: 4, season: SPRING | SUMMER | AUTUMN),
    Seed(id: 8, name: "辣椒", growthFormula: 4, compost: 4, mansure: -8, season: SUMMER | AUTUMN),
    Seed(id: 9, name: "石榴", growthFormula: -8, compost: 4, mansure: 4, season: SPRING | SUMMER),
    Seed(id: 10, name: "土豆", growthFormula: 2, compost: 2, mansure: -4, season: SPRING | AUTUMN | WINTER),
    Seed(id: 11, name: "南瓜", growthFormula: -4, compost: 2, mansure: 2, season: AUTUMN | WINTER),
    Seed(id: 12, name: "番茄", growthFormula: -2, compost: -2, mansure: 4, season: SPRING | SUMMER | AUTUMN),
    Seed(id: 13, name: "西瓜", growthFormula: 4, compost: -2, mansure: -2, season: SPRING | SUMMER)
]


func toString(i: Int) -> String {
    return i > 0 ? "+" + String(i) : String(i)
}

struct CustomSteper: View {
    @Binding var value: Int
    @State private var notificationFeedback = UINotificationFeedbackGenerator()
    @State private var impactFeedback = UIImpactFeedbackGenerator()

    var body: some View {
        HStack {
            Image(systemName: "minus.circle").foregroundColor(value == 0 ? .gray : .blue)
                .onTapGesture {
                    if (value > 0) {
                        value -= 1
                        impactFeedback.impactOccurred()
                    }
                }
            Text("\(value)").frame(width: 32)
            Image(systemName: "plus.circle").foregroundColor(value == 12 ? .gray : .blue)
                .onTapGesture {
                    if (value < 12) {
                        value += 1
                        impactFeedback.impactOccurred()
                    }
                }
        }
    }
}

struct RecordView: View {
    @Binding var record: Record
    var isLoved: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(record.seed.name).frame(width: 64, alignment: .leading)
                Image(systemName: "heart.slash").existWhen(!isLoved)

                Spacer()

                HStack(spacing: 0) {
                    Text(record.seed.season & SPRING == 0 ? "○" : "●")
                        .foregroundColor(record.seed.season & SPRING == 0 ? .gray : .green).font(.footnote)
//                        .existWhen(record.seed.season & SPRING != 0)
                    Text(record.seed.season & SUMMER == 0 ? "○" : "●")
                        .foregroundColor(record.seed.season & SUMMER == 0 ? .gray : .red).font(.footnote)
//                        .existWhen(record.seed.season & SUMMER != 0)
                    Text(record.seed.season & AUTUMN == 0 ? "○" : "●")
                        .foregroundColor(record.seed.season & AUTUMN == 0 ? .gray : .yellow).font(.footnote)
//                        .existWhen(record.seed.season & AUTUMN != 0)
                    Text(record.seed.season & WINTER == 0 ? "○" : "●")
                        .foregroundColor(record.seed.season & WINTER == 0 ? .gray : .blue).font(.footnote)
//                        .existWhen(record.seed.season & WINTER != 0)
                }
                
            }.padding(.top, 8).padding(.bottom, 8)
            HStack {
                Text("养分:").font(.footnote).foregroundColor(.secondary)
                Text(toString(i: record.seed.growthFormula * record.count / (isLoved ? 1 : 2)))
                    .frame(width: 32).foregroundColor(.blue)
                Text(toString(i: record.seed.compost * record.count / (isLoved ? 1 : 2)))
                    .frame(width: 32).foregroundColor(.yellow)
                Text(toString(i: record.seed.mansure * record.count / (isLoved ? 1 : 2)))
                    .frame(width: 32).foregroundColor(.purple)
                Spacer()
                CustomSteper(value: $record.count)
            }.padding(.bottom, 8)
        }
    }
}

struct SeedPicker: View {
    @State private var impactFeedback = UIImpactFeedbackGenerator()

    @Binding var selection: Int
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        List {
            ForEach(seeds) { item in
                Button(action: {
                    selection = item.id
                    impactFeedback.impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack {
                        Text(item.name).frame(width: 64, alignment: .leading)

                        HStack(spacing: 0) {
                            Text(item.season & SPRING == 0 ? "○" : "●")
                                .foregroundColor(item.season & SPRING == 0 ? .gray : .green).font(.footnote)
                            Text(item.season & SUMMER == 0 ? "○" : "●")
                                .foregroundColor(item.season & SUMMER == 0 ? .gray : .red).font(.footnote)
                            Text(item.season & AUTUMN == 0 ? "○" : "●")
                                .foregroundColor(item.season & AUTUMN == 0 ? .gray : .yellow).font(.footnote)
                            Text(item.season & WINTER == 0 ? "○" : "●")
                                .foregroundColor(item.season & WINTER == 0 ? .gray : .blue).font(.footnote)
                        }
                        Spacer()
                        Text(toString(i: item.growthFormula)).frame(width: 32).foregroundColor(.blue)
                        Text(toString(i: item.compost)).frame(width: 32).foregroundColor(.yellow)
                        Text(toString(i: item.mansure)).frame(width: 32).foregroundColor(.purple)
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .visiableWhen(selection == item.id)
                    }
                })
            }
        }.navigationTitle("选择作物种类")
    }
}

struct AddSeedView: View {
    @State private var notificationFeedback = UINotificationFeedbackGenerator()

    @State private var selectedId: Int = -1
    @State private var countString: String = ""
    @Binding var records:[Record]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var frameworks = ["UIKit", "Core Data", "CloudKit", "SwiftUI"]
    @State private var selectedFrameworkIndex = 0
    
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
                
                NavigationLink(destination: SeedPicker(selection: $selectedId)) {
                    Text("种类")
                    Spacer()
                    Text(selectedId != -1 ? seeds[selectedId].name : "").foregroundColor(.secondary)
                }
            }
            
        }
        .navigationTitle("添加作物")
        .listStyle(InsetGroupedListStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if (selectedId != -1) {
                        records.append(Record(seed: seeds[selectedId], count: Int(countString) ?? 0))
                        notificationFeedback.notificationOccurred(.success)
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

struct ContentView: View {
    @State private var notificationFeedback = UINotificationFeedbackGenerator()
    @State private var impactFeedback = UIImpactFeedbackGenerator()
    @State private var showNotLoved = true
    @State private var editing:EditMode = EditMode.inactive
    @State private var value = 0
    @State private var records:[Record] = [Record(seed: seeds[1], count: 4)]
    @State private var season = 0
    
    func bindRecords(index: Int) -> Binding<Record> {
        return Binding(get: {records[index]}, set: {records[index] = $0})
    }
    
    var body: some View {
        List {
            Section(header: Text("季节")) {
                GeometryReader { metrics in
                    HStack (spacing: 0) {
                        Image(systemName: "leaf")
                            .foregroundColor(season & SPRING != 0 ? .green : .gray).font(.title)
                            .onTapGesture {
                                if (season == SPRING) {
                                    season = 0
                                } else {
                                    season = SPRING
                                }
                                impactFeedback.impactOccurred()
                            }
                            .onLongPressGesture {
                                season ^= SPRING
                                notificationFeedback.notificationOccurred(.success)
                                notificationFeedback.prepare()
                            }
                            .frame(width: metrics.size.width * 0.25)
                        Image(systemName: "sun.max")
                            .foregroundColor(season & SUMMER != 0 ? .red : .gray).font(.title)
                            .onTapGesture {
                                if (season == SUMMER) {
                                    season = 0
                                } else {
                                    season = SUMMER
                                }
                                impactFeedback.impactOccurred()
                            }
                            .onLongPressGesture {
                                season ^= SUMMER
                                notificationFeedback.notificationOccurred(.success)
                                notificationFeedback.prepare()
                            }
                            .frame(width: metrics.size.width * 0.25)
                        Image(systemName: "wind")
                            .foregroundColor(season & AUTUMN != 0 ? .yellow : .gray).font(.title)
                            .onTapGesture {
                                if (season == AUTUMN) {
                                    season = 0
                                } else {
                                    season = AUTUMN
                                }
                                impactFeedback.impactOccurred()
                            }
                            .onLongPressGesture {
                                season ^= AUTUMN
                                notificationFeedback.notificationOccurred(.success)
                                notificationFeedback.prepare()
                                
                            }
                            .frame(width: metrics.size.width * 0.25)
                        Image(systemName: "snow")
                            .foregroundColor(season & WINTER != 0 ? .blue : .gray).font(.title)
                            .onTapGesture {
                                if (season == WINTER) {
                                    season = 0
                                } else {
                                    season = WINTER
                                }
                                impactFeedback.impactOccurred()
                            }
                            .onLongPressGesture {
                                season ^= WINTER
                                notificationFeedback.notificationOccurred(.success)
                                notificationFeedback.prepare()
                            }
                            .frame(width: metrics.size.width * 0.25)
                    }
                }
                
            }
            Section(header: Text("所种植物")) {
                ForEach(Array(zip(records.indices, records)), id: \.1.id) { i, record in
                    let isLoved = record.seed.season & season >= season
                    RecordView(record: bindRecords(index: i), isLoved: isLoved)
                        .existWhen(showNotLoved || isLoved)
                }
                .onDelete(perform: { indexSet in
                    records.remove(atOffsets: indexSet)
                })
                .onMove(perform: { indices, newOffset in
                    records.move(fromOffsets: indices, toOffset: newOffset)
                })
            }
            Section(header: Text("养分消耗统计")) {
                let growthFormulaCost = records.filter{ item in
                    showNotLoved || item.seed.season & season >= season
                }.reduce(0, { result, record in
                    result + record.seed.growthFormula * record.count / (record.seed.season & season >= season ? 1 : 2)
                })
                
                let compostCost = records.filter{ item in
                    showNotLoved || item.seed.season & season >= season
                }.reduce(0, { result, record in
                    result + record.seed.compost * record.count * (record.seed.season & season >= season ? 1 : 2)
                })
                
                let mansureCost = records.filter{ item in
                    showNotLoved || item.seed.season & season >= season
                }.reduce(0, { result, record in
                    result + record.seed.mansure * record.count * (record.seed.season & season >= season ? 1 : 2)
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

                    NavigationLink(destination: AddSeedView(records: $records)) {
                        Image(systemName: "plus").foregroundColor(.blue).font(.title2).existWhen(self.editing == .inactive)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    private var selectedId = -1

    static var previews: some View {
        NavigationView {
            ContentView()
                .navigationTitle("Plant Master")
        }
    }
}
