//
//  RoutineAPI.swift
//  Runner
//
//  Created by hawon on 5/11/26.
//
import Moya
import Alamofire

enum RoutineAPI {
    case routines(date: String, accessToken: String)
}

extension RoutineAPI: TargetType {
    var baseURL: URL {
        guard
            let base = Bundle.main.object(
                forInfoDictionaryKey: "KDHApiBaseURL"
            ) as? String,
            !base.isEmpty,
            let url = URL(string: base)
        else {
            fatalError("KDHApiBaseURL 설정 오류")
        }
        return url
    }

    var path: String {
        switch self {
        case .routines:
            return "/routines"
        }
    }

    var method: Moya.Method {
        switch self {
        case .routines:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .routines(date, _):
            return .requestParameters(parameters: ["date": date], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String : String]? {
        switch self {
        case let .routines(_, accessToken):
            return [
                "Accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
        }
    }

    var sampleData: Data { Data() }
}
