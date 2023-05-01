//
//  InlineHostingViewAppApp.swift
//  InlineHostingViewApp
//
//  Created by Stephan Casas on 4/30/23.
//

import SwiftUI;
import Combine;

@main
struct InlineHostingViewAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


// MARK: - Sample Usage / Main Content View
struct ContentView: View {
    let unreadPublisher = IncrementingCounter.Publisher();
    let alertPublisher = IncrementingCounter.Publisher();
    let taskPublisher = IncrementingCounter.Publisher();
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            InlineHostingView(
                "You have {{ content }} unread messages, {{ content }} unread alerts, and {{ content }} tasks due today.",
                { IncrementingCounter(withCount: 11, incrementOn: self.unreadPublisher).fill(.indigo) },
                { IncrementingCounter(withCount: 2, incrementOn: self.alertPublisher).fill(.red) },
                { IncrementingCounter(withCount: 3, incrementOn: self.taskPublisher).fill(.blue) }
            )
            .font(.boldSystemFont(ofSize: 22)).color(.secondaryLabelColor)
            .padding()
            .background(RoundedRectangle(cornerRadius: 22)
                .shadow(radius: 10)
                .foregroundStyle(.quaternary))
            
            Spacer()
            
            VStack {
                Button("Increment Unread", action: {unreadPublisher.send(1)});
                Button("Increment Priority", action: {alertPublisher.send(1)});
                Button("Increment Task", action: {taskPublisher.send(1)});
            }
            
            Spacer()
            
        }.padding()
        
    }
}

// MARK: - Sample Counter View

/// Ralph Ragland

struct IncrementingCounter: View {
    
    typealias Publisher = PassthroughSubject<Int, Never>;
    
    @State var count: Int;
    let countPublisher: Publisher;
    
    private var __fill: Color = .indigo;
    
    init(withCount: Int = 0, incrementOn: Publisher) {
        self.count = withCount;
        self.countPublisher = incrementOn;
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12.5)
                .foregroundColor(self.__fill)
                .shadow(radius: 2.0)
            HStack{
                Spacer()
                Text("\(count)")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .light))
                    .onReceive(countPublisher) { increment in
                        self.count += increment;
                    }
                Spacer();
            }
        }.frame(minWidth: 30, minHeight: 30)
    }
    
    func fill(_ fill: Color) -> Self {
        var copy = self;
        copy.__fill = fill;
        
        return copy;
    }
}
