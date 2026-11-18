//
//  MeigenWidget.swift
//  MeigenWidgetExtension
//  
//  Created by keeki-fami on 2026/11/14
//  
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

// 表示するデータの提供
struct Provider: AppIntentTimelineProvider {
    
    typealias Entry = MeigenEntry
    typealias Intent = FavoriteBook
    
    
    func placeholder(in context: Context) -> MeigenEntry {
        MeigenEntry(
            date: Date(),
            text: "Sample",
            fileNamePath: nil
        )
    }
    
    func snapshot(for configuration: FavoriteBook, in context: Context) async -> MeigenEntry {
            return MeigenEntry(
                date: Date(),
                text: "Sampl",
                fileNamePath: nil
            )
    }
    
    func timeline(for configuration: FavoriteBook, in context: Context) async -> Timeline<MeigenEntry>  {
        let currentDate = Date()
        let entry = fetchRandomMeigen()
        
        switch configuration.mode {
        case .random:
            let nextUpdateDate = Calendar.current.date(byAdding: .second, value: configuration.$span.wrappedValue.meigenSpan, to: currentDate)!

            return Timeline(
                entries: [entry],
                policy: .after(nextUpdateDate)
            )
        case .single:
            // TODO: 固定表示を行う。
            if let meigen = configuration.meigen {
                let entry = MeigenEntry(
                    date: Date(),
                    text: meigen.text,
                    fileNamePath: meigen.path
                )
                return Timeline(
                    entries: [entry],
                    policy: .never
                )
            } else {
                let entry = MeigenEntry(
                    date: Date(),
                    text: "名言が見つかりません",
                    fileNamePath: nil
                )
                return Timeline(
                    entries: [entry],
                    policy: .never
                )
            }
        }
    }
    
    func fetchRandomMeigen() -> MeigenEntry {
        do {
            let container = try SharedModelContainer.create()
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<QuoteRecord>(
                sortBy: [
                    SortDescriptor(\.createdAt, order: .reverse)
                ]
            )
            let models = try context.fetch(descriptor).randomElement()
            if let model = models {
                return MeigenEntry (
                    date: .now,
                    text: model.text,
                    fileNamePath: model.imageFilename
                )
            } else {
                return MeigenEntry(
                    date: .now,
                    text: "Sampl",
                    fileNamePath: nil
                )
            }
        } catch {
            print("Widget fetch error: \(error)")

            return MeigenEntry(
                date: .now,
                text: "名言を追加しよう",
                fileNamePath: nil
            )
        }
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}


struct MeigenEntry: TimelineEntry {
    let date: Date // widgetを表示する日付を指定する必要がある。
    let text: String
    let fileNamePath: String?
}

// ウィジェットのデザイン
struct MeigenWidgetEntryView : View {
    var entry: Provider.Entry
    private let imageStorageService = ImageStorageService()

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = imageStorageService.load(filename: entry.fileNamePath) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .overlay(alignment: .bottomLeading) {
                            Text("\(entry.text)")
                                .font(.system(size: 15, weight: .semibold, design: .serif))
                                .padding()
                                .shadow(color: .black, radius: 10, x: 0, y: 0)
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height*0.2
                                )
                                .background(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .clear, location: 0.0),
                                            .init(color: .black.opacity(0.8), location: 0.2),
                                            .init(color: .black.opacity(0.8), location: 1.0),
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                } else {
                    LinearGradient(
                        colors: [.indigo.opacity(0.85), .black.opacity(0.92)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .overlay(alignment: .bottomLeading) {
                        Text("\(entry.text)")
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                            .padding()
                            .shadow(color: .black, radius: 10, x: 0, y: 0)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                    }
                }
            }
        }
    }
}

// ウィジェット
struct MeigenWidget: Widget {
    let kind: String = "MeigenWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: FavoriteBook.self,
            provider: Provider()
        ) { entry in
            MeigenWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
    }
}

// Stringに準拠する？
// AppEnumへの準拠条件は？
enum MeigenDisplayMode: String, AppEnum {
    case single
    case random
    
    // 型全体の解説
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Meigen表示設定"
    
    // 個々のケースの解説
    static let caseDisplayRepresentations: [Self : DisplayRepresentation] = [
        .single: "固定",
        .random: "ランダム",
    ]
}

enum MeigenUpdateSpan: String, AppEnum {
    case min15
    case min30
    case hour1
    case hour3
    case hour6
    case hour12
    
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "更新間隔"
    static let caseDisplayRepresentations: [MeigenUpdateSpan : DisplayRepresentation] = [
        .min15: "15分",
        .min30: "30分",
        .hour1: "1時間",
        .hour3: "3時間",
        .hour6: "6時間",
        .hour12: "12時間"
    ]
}

extension MeigenUpdateSpan {
    var meigenSpan: Int {
        switch self {
        case .min15: return 15 * 60
        case .min30: return 30 * 60
        case .hour1: return 1 * 60 * 60
        case .hour3: return 3 * 60 * 60
        case .hour6: return 6 * 60 * 60
        case .hour12: return 12 * 60 * 60
        @unknown default: return 24 * 60 * 60
        }
    }
}


struct MeigenEntity: AppEntity {
    
    static var defaultQuery = MeigenQuery()
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "取得"
    
    let id: QuoteRecord.ID
    var text: String
    var author: String?
    var path: String?
//    static let typeDisplayRepresentation: TypeDisplayRepresentation
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(self.text)",
            subtitle: "\(self.author ?? "unknown")",
            image: nil
        )
    }
    
    init(record: QuoteRecord) {
        self.id = record.id
        self.text = record.text
        self.author = record.author
        self.path = record.imageFilename
    }
    
}

struct MeigenQuery: EntityQuery {

    func entities(
        for identifiers: [MeigenEntity.ID]
    ) async throws -> [MeigenEntity] {
        let container = try SharedModelContainer.create()
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<QuoteRecord>(
            sortBy: [
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )
        return try context.fetch(descriptor).filter { identifiers.contains($0.id) }.map{ MeigenEntity(record: $0) }
    }

    func suggestedEntities() async throws -> [MeigenEntity] {
        let container = try SharedModelContainer.create()
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<QuoteRecord>(
            sortBy: [
                SortDescriptor(\.createdAt, order: .reverse)
            ]
        )
        let models = try context.fetch(descriptor).map{MeigenEntity(record: $0)}
        return models
    }
}

// AppIntentConfiguration
struct FavoriteBook: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Favorite Book"
    static var description = IntentDescription("Shows a picture of your favorite book!")
    
    @Parameter(title: "DisplayMode", default: .random)
    var mode: MeigenDisplayMode
    
    @Parameter(title: "UpdateSpan", default: .min30)
    var span: MeigenUpdateSpan
    
    @Parameter(title: "FixedMeigen", default: nil)
    var meigen: MeigenEntity?
    
    static var parameterSummary: some ParameterSummary {
        Switch(\.$mode) {
            Case(.random) {
                Summary {
                    \.$mode
                    \.$span
                }
            }
            DefaultCase() {
                Summary {
                    \.$mode
                    \.$meigen
                }
            }
        }
    }
    
}

#Preview(as: .systemSmall) {
    MeigenWidget()
} timeline: {
    MeigenEntry(date: .now, text: "Sample1", fileNamePath: nil)
    MeigenEntry(date: .now, text: "Sample2", fileNamePath: nil)
}
