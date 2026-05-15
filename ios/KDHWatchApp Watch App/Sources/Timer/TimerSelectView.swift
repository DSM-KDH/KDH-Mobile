#if os(watchOS)
//
//  TimerSelectView.swift
//  Runner
//
//  Created by hawon on 4/24/26.
//

import SwiftUI

enum TimerDestination {
    case interval
    case custom
    case metronome
}

struct TimerSelectView: View {
    @State private var destination: TimerDestination? = nil
    private let timerOptions: [(title: String, color: Color, arrow: String, dest: TimerDestination)] = [
        ("인터벌 타이머", .red50, arrow: "arrow1", .interval),
        ("사용자 설정 타이머", .red100, arrow: "arrow2", .custom),
        ("메트로놈", .red200, arrow: "arrow3", .metronome),
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("타이머 선택")
                    .font(.kdf(.body3))
                    .foregroundStyle(.gray800)
                    .padding(.top, 5)
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(timerOptions, id: \.title) { option in
                            TimerOptionButton(
                                title: option.title,
                                backgroundColor: option.color,
                                arrow: option.arrow
                            ) {
                                destination = option.dest
                            }
                        }
                    }
                    .padding(.top, 6)
                    .padding(.horizontal, 12)
                }
            }
            .background(Color.background)
            .navigationDestination(item: $destination) { dest in
                switch dest {
                case .interval:  IntervalTimerView()
                case .custom:    CustomTimerView()
                case .metronome: MetronomeRunView()
                }
            }
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        switch destination {
        case .interval:
            IntervalTimerView()
        case .custom:
            CustomTimerView()
        case .metronome:
            MetronomeRunView()
        case .none:
            EmptyView()
        }
    }
}

#Preview {
    TimerSelectView()
}
#endif
