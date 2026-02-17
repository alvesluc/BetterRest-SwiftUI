//
//  ContentView.swift
//  BetterRest
//
//  Created by Macedo on 13/02/26.
//

import CoreML
import SwiftUI

struct ContentView: View {
    static private var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    @State private var wakeUpAt = defaultWakeUpTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker(
                        "Please enter a time",
                        selection: $wakeUpAt,
                        displayedComponents: .hourAndMinute
                    )
                }
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12)
                }
                
                Section("Daily coffee intake") {
                    Picker("Cups of coffee", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) { number in
                            Text("^[\(number) cup](inflect: true)")
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: .infinity, height: 120)
                }
                Section("Recommended bedtime") {
                    Text("\(calculateBedtime())")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: wakeUpAt
            )
            let hourInSeconds = (components.hour ?? 0) * 60 * 60
            let minutesInSeconds = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(
                wake: Double(hourInSeconds + minutesInSeconds),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )
            
            let sleepTime = wakeUpAt - prediction.actualSleep
            
            return "\(sleepTime.formatted(date: .omitted, time: .shortened))"
        } catch {
            return "Couldn't calculate bedtime"
        }
    }
}

#Preview {
    ContentView()
}
