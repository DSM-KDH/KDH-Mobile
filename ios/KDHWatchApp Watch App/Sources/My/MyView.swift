#if os(watchOS)
//
//  MyView.swift
//  Runner
//
//  Created by hawon on 4/17/26.
//

import SwiftUI

struct MyView: View {
    @EnvironmentObject private var connectivityManager: WatchConnectivityManager

    @State private var my: My = .init(
        name: "",
        info: ""
    )

    @State private var isLoading = false
    @State private var weightHistory: [MonthlyWeightPoint] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image("profile")
                        .resizable()
                        .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(my.name.isEmpty ? "사용자" : my.name)
                            .foregroundStyle(Color.gray800)
                            .font(.kdf(.caption1))

                        Text(
                            (my.info?.isEmpty ?? true)
                            ? "사용자 정보를 입력해주세요"
                            : my.info!
                        )
                        .foregroundStyle(Color.gray300)
                        .font(.kdf(.caption4))
                    }

                    Spacer()
                }
                .padding(.leading, 20)

                VStack(alignment: .leading, spacing: 8) {
                    Text("몸무게 변화")
                        .font(.kdf(.caption1))
                        .foregroundStyle(.gray800)

                    if weightHistory.count < 3 {
                        Text("데이터가 아직 쌓이지 않았어요")
                            .font(.kdf(.caption4))
                            .foregroundStyle(.gray400)
                            .frame(maxWidth: .infinity, minHeight: 110)
                    } else {
                        WeightHistoryGraph(points: weightHistory)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 12)

            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .background(Color.background)
        .task {
            await fetchMyInfo()
        }
    }
}

private extension MyView {
    func fetchMyInfo() async {
        guard !isLoading else {
            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        guard
            let accessToken = connectivityManager.accessToken(),
            !accessToken.isEmpty
        else {
            print("[MyView] AccessToken 없음")
            return
        }

        do {
            let user = try await UsersService.shared.fetchMe(
                accessToken: accessToken
            )

            await MainActor.run {
                my = .init(
                    name: user.name,
                    info: my.info
                )
            }

        } catch {
            print("[MyView] fetchMe error: \(error)")
        }

        do {
            let profile = try await UsersService.shared.fetchProfile(
                accessToken: accessToken
            )

            let profileText =
                "\(Int(profile.heightCm))cm · " +
                "\(Int(profile.weightKg))kg · " +
                "\(profile.gender == "MALE" ? "남" : "여")"

            await MainActor.run {
                my = .init(
                    name: my.name,
                    info: profileText
                )
            }

        } catch {
            print("[MyView] fetchProfile error: \(error)")
        }

        do {
            let history = try await UsersService.shared.fetchProfileHistory(
                accessToken: accessToken
            )

            let monthly = makeMonthlyWeightPoints(from: history)

            await MainActor.run {
                weightHistory = monthly
            }
        } catch {
            print("[MyView] fetchProfileHistory error: \(error)")
            await MainActor.run {
                weightHistory = []
            }
        }
    }

    func makeMonthlyWeightPoints(
        from history: [ProfileHistoryResponse]
    ) -> [MonthlyWeightPoint] {
        guard !history.isEmpty else { return [] }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoWithoutFraction = ISO8601DateFormatter()
        isoWithoutFraction.formatOptions = [.withInternetDateTime]
        let calendar = Calendar(identifier: .gregorian)

        var latestPerMonth: [DateComponents: HistoryPoint] = [:]

        for item in history {
            let date =
                iso.date(from: item.recordedAt) ??
                isoWithoutFraction.date(from: item.recordedAt)

            guard let date else { continue }

            let comps = calendar.dateComponents([.year, .month], from: date)
            let current = HistoryPoint(date: date, weight: item.weightKg)

            if let existing = latestPerMonth[comps] {
                if current.date > existing.date {
                    latestPerMonth[comps] = current
                }
            } else {
                latestPerMonth[comps] = current
            }
        }

        var monthlyPoints = latestPerMonth.compactMap { key, value -> MonthlyWeightPoint? in
            guard let month = key.month else { return nil }
            return MonthlyWeightPoint(
                monthLabel: "\(month)월",
                date: value.date,
                weight: value.weight
            )
        }
        .sorted { $0.date < $1.date }

        guard monthlyPoints.count >= 3 else { return monthlyPoints }

        let displayCount = min(max(3, monthlyPoints.count), 6)
        if monthlyPoints.count > displayCount {
            monthlyPoints = Array(monthlyPoints.suffix(displayCount))
        }

        return monthlyPoints
    }
}

private struct My: Identifiable {
    let id = UUID()
    let name: String
    var info: String?
}

private struct HistoryPoint {
    let date: Date
    let weight: Double
}

#Preview {
    MyView()
}
#endif
