//
//  UsersService.swift
//  Runner
//
//  Created by hawon on 5/12/26.
//

#if os(watchOS)

import Foundation
import Moya

struct UsersService {
    static let shared = UsersService()

    private let provider = MoyaProvider<UsersAPI>(
        plugins: [MoyaLogginPlugin()]
    )

    private init() {}

    func fetchProfile(
        accessToken: String
    ) async throws -> ProfileResponse {
        let target = UsersAPI.profile(
            accessToken: accessToken
        )
        let response = try await withCheckedThrowingContinuation {
            continuation in
            provider.request(target) { result in
                switch result {
                case let .success(response):
                    continuation.resume(returning: response)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }

        let raw = String(
            data: response.data,
            encoding: .utf8
        ) ?? ""

        print("[UsersAPI] request target=\(target)")
        print("[UsersAPI] response headers=\(response.response?.allHeaderFields ?? [:])")

        print("[UsersAPI] statusCode=\(response.statusCode)")
        print("[UsersAPI] RAW RESPONSE=\(raw)")

        guard (200...299).contains(response.statusCode) else {
            throw NSError(
                domain: "UsersService",
                code: response.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: "프로필 조회 실패"
                ]
            )
        }

        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.hasPrefix("{") else {

            print("[UsersAPI] HTML RESPONSE DETECTED")

            throw NSError(
                domain: "UsersService",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey: "서버가 JSON 대신 HTML 응답 반환"
                ]
            )
        }

        do {

            let decoder = JSONDecoder()

            return try decoder.decode(
                ProfileResponse.self,
                from: response.data
            )

        } catch {

            print("[UsersAPI] DECODE ERROR \(error)")

            throw NSError(
                domain: "UsersService",
                code: 3,
                userInfo: [
                    NSLocalizedDescriptionKey: "프로필 응답 파싱 실패"
                ]
            )
        }
    }

    func fetchMe(
        accessToken: String
    ) async throws -> UserResponse {
        let target = UsersAPI.me(
            accessToken: accessToken
        )
        let response = try await withCheckedThrowingContinuation {
            continuation in
            provider.request(target) { result in
                switch result {
                case let .success(response):
                    continuation.resume(returning: response)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }

        let raw = String(
            data: response.data,
            encoding: .utf8
        ) ?? ""

        print("[UsersAPI] request target=\(target)")
        print("[UsersAPI] response headers=\(response.response?.allHeaderFields ?? [:])")

        print("[UsersAPI] statusCode=\(response.statusCode)")
        print("[UsersAPI] RAW RESPONSE=\(raw)")

        guard (200...299).contains(response.statusCode) else {
            throw NSError(
                domain: "UsersService",
                code: response.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: "사용자 정보 조회 실패"
                ]
            )
        }

        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.hasPrefix("{") else {

            print("[UsersAPI] HTML RESPONSE DETECTED")

            throw NSError(
                domain: "UsersService",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey: "서버가 JSON 대신 HTML 응답 반환"
                ]
            )
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(
                UserResponse.self,
                from: response.data
            )

        } catch {

            print("[UsersAPI] DECODE ERROR \(error)")

            throw NSError(
                domain: "UsersService",
                code: 3,
                userInfo: [
                    NSLocalizedDescriptionKey: "사용자 정보 응답 파싱 실패"
                ]
            )
        }
    }
}

#endif
