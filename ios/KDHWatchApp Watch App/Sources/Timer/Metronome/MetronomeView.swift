#if os(watchOS)
import SwiftUI

struct MetronomeView: View {
    @State private var bpm: Int = 90
    @State private var repeatHours: Int = 0
    @State private var repeatMinutes: Int = 20
    @State private var navigateToRun = false

    private var totalSeconds: Int {
        (repeatHours * 60 + repeatMinutes) * 60
    }

    private var isValid: Bool {
        totalSeconds > 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("메트로놈")
                            .font(.kdf(.body3))
                            .foregroundStyle(.gray800)
                            .padding(.top, 6)

                        Text("BPM을 설정해주세요")
                            .font(.kdf(.caption1))
                            .foregroundStyle(.gray800)

                        HStack {
                            Picker("BPM", selection: $bpm) {
                                ForEach(40...220, id: \.self) { value in
                                    Text("\(value)").tag(value)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 72, height: 96)

                            Text("BPM")
                                .font(.kdf(.caption2))
                                .foregroundStyle(.gray700)
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red50.opacity(0.5))
                        )

                        Text("타이머를 몇 시간동안 반복할까요?")
                            .font(.kdf(.caption1))
                            .foregroundStyle(.gray800)
                            .padding(.top, 6)

                        HStack(spacing: 6) {
                            Picker("시", selection: $repeatHours) {
                                ForEach(0..<24, id: \.self) { h in Text("\(h)").tag(h) }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 44, height: 96)

                            Text("시간").font(.kdf(.caption4))

                            Text("-").font(.kdf(.caption4)).foregroundStyle(.gray500)

                            Picker("분", selection: $repeatMinutes) {
                                ForEach(0..<60, id: \.self) { m in Text("\(m)").tag(m) }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 44, height: 96)

                            Text("분").font(.kdf(.caption4))
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red50.opacity(0.5))
                        )
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                }

                TimerStartButton(
                    isEnabled: isValid,
                    action: { navigateToRun = true }
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .background(Color.background)
            .environment(\.colorScheme, .light)
            .navigationDestination(isPresented: $navigateToRun) {
                MetronomeRunView(bpm: bpm, totalSeconds: totalSeconds)
            }
        }
    }
}
#endif
