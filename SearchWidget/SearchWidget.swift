//
//  SearchWidget.swift
//  SearchWidget
//
//  Created by Jae hyung Kim on 5/14/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

/*
TimelineEntry는 date 라는 필수 프로퍼티를 가지는 프로토콜이고,
date는 위젯을 업데이트하는 시간을 담고 있다.
 */
struct SimpleEntry: TimelineEntry {
    let date: Date
//    let emoji: String
}

struct SearchWidgetEntryView : View {
//    var entry: Provider.Entry

    var body: some View {
        VStack {
            SearchBarView()
        }
        
    }
}

struct SearchBarView: View {
    var body: some View {
        VStack {
            logoView
            Spacer()
            FakeSearchView()
                .widgetURL(URL(string: "widget://Search"))
            Spacer()
        }
    }
    
    var logoView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("이번엔 어디서")
                    .multilineTextAlignment(.leading)
                    .padding(.leading)
                    .font(.title2)
                    .bold()
                    .padding(.top)
                Spacer()
                Image("logo")
                    .resizable()
                    .frame(width: 20,height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
            
            Text("추억을 쌓고 싶으신가요?")
                .multilineTextAlignment(.leading)
                .padding(.leading)
                .font(.subheadline)
                .padding(.bottom, 2)
        }
    }
}

struct FakeSearchView: View {
    var body: some View {
        Link(destination: URL(string: "widget://Search")!,
             label: {
            HStack {
                Image(systemName: "map")
                    .resizable()
                    .foregroundStyle(.orange)
                    .frame(width: 25,height: 25)
                    .padding(.leading)
                Text("장소를 검색해 보세요")
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .padding(.leading, 4)
                
                Spacer()
                
                Image(systemName: "location.magnifyingglass")
                    .resizable()
                    .foregroundStyle(.orange)
                    .frame(width: 25,height: 25)
                    .padding(.trailing)
            }
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(
                        color: Color.red.opacity(0.3),
                        radius: 10,
                        x: 0,
                        y: 0
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.orange, lineWidth: 1.4)
            )
        })
                //        Link(destination: URL(string: "widget://Search")!,
                //             label: {
                //
                //        })
    }
}

struct SearchWidget: Widget {
    let kind: String = "SearchWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SearchWidgetEntryView()
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                SearchWidgetEntryView()
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Search Map")
        .description("MapBeDiary Search Map Widget")
        .supportedFamilies([.systemMedium])
    }
}

@available(iOS 17, *)
#Preview(as: .systemMedium) {
    SearchWidget()
} timeline: {
    SimpleEntry(date: .now)
    SimpleEntry(date: .now)
}
