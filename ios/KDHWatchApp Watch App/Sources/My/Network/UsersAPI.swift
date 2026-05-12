//
//  UsersAPI.swift
//  Runner
//
//  Created by hawon on 5/12/26.
//
import Foundation
import Moya
import Alamofire

enum UsersAPI {
    case profile(accessToken: String)
}

extension UsersAPI: TargetType {

    var baseURL: URL {
        guard
            let base = Bundle.main.object(
                forInfoDictionaryKey: "KDHApiBaseURL"
            ) as? String,
            !base.isEmpty,
            let url = URL(string: "\(base)/users")
        else {
            fatalError("KDHApiBaseURL 설정 오류")
        }
        return url
    }

    var path: String {
        switch self {
        case .profile:
            return "/me/profile"
        }
    }

    var method: Moya.Method {
        switch self {
        case .profile:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .profile:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        switch self {
        case let .profile(accessToken):
            return [
                "Accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
        }
    }
}
