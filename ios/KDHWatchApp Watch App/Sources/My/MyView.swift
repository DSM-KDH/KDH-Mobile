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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
    }
}

private struct My: Identifiable {
    let id = UUID()
    let name: String
    var info: String?
}

#Preview {
    MyView()
}
#endif
