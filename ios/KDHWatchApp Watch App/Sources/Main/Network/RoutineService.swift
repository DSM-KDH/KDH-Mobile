//
//  RoutineService.swift
//  Runner
//
//  Created by hawon on 5/11/26.
//
#if os(watchOS)
import Foundation
import Moya

struct RoutineService {

    static let shared = RoutineService()

    private let provider = MoyaProvider<RoutineAPI>(
        plugins: [MoyaLogginPlugin()]
    )

    private init() {}

    func fetchTodayRoutine(
        accessToken: String
    ) async throws -> RoutineResponse {

        let rawBase = Bundle.main.object(
            forInfoDictionaryKey: "KDHApiBaseURL"
        )

        print("[WatchAPI] KDHApiBaseURL raw=\(String(describing: rawBase))")

        guard
            let base = rawBase as? String,
            !base.isEmpty,
            let baseURL = URL(string: base)
        else {
            throw NSError(
                domain: "WatchRoutineService",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "KDHApiBaseURL 설정 없음"
                ]
            )
        }

        let today = Self.dateFormatter.string(from: Date())

        let target = RoutineAPI.routines(
            baseURL: baseURL,
            date: today,
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

        guard (200...299).contains(response.statusCode) else {

            let body = String(
                data: response.data,
                encoding: .utf8
            ) ?? ""

            print("[WatchAPI] non-2xx body=\(body)")

            throw NSError(
                domain: "WatchRoutineService",
                code: response.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: "루틴 API 실패"
                ]
            )
        }

        do {

            return try JSONDecoder().decode(
                RoutineResponse.self,
                from: response.data
            )

        } catch {

            let raw = String(
                data: response.data,
                encoding: .utf8
            ) ?? ""

            print("[WatchAPI] DECODE ERROR \(error)")
            print("[WatchAPI] RAW RESPONSE \(raw)")

            throw NSError(
                domain: "WatchRoutineService",
                code: 3,
                userInfo: [
                    NSLocalizedDescriptionKey: "루틴 응답 파싱 실패"
                ]
            )
        }
    }
}

private extension RoutineService {

    static let dateFormatter: DateFormatter = {

        let formatter = DateFormatter()

        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }()
}
#endif
