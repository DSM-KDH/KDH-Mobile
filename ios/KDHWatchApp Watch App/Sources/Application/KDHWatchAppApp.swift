//
//  KDHWatchAppApp.swift
//  KDHWatchApp Watch App
//
//  Created by hawon on 4/1/26.
//

#if os(watchOS)
import SwiftUI
import WatchConnectivity
import Security
import Combine

@main
struct KDHWatchApp_Watch_AppApp: App {
    @StateObject private var connectivityManager = WatchConnectivityManager()

    var body: some Scene {
        WindowGroup {
            WatchTabbarView()
                .environmentObject(connectivityManager)
                .onAppear {
                    connectivityManager.activate()
                }
        }
    }
}
final class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var isReachable: Bool = false
    @Published var lastErrorMessage: String?
    @Published var hasAccessToken: Bool = false
    private let tokenStore = WatchTokenStore()

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        print("[WatchConnectivity] activate() called")
    }

    func accessToken() -> String? {
        tokenStore.readAccessToken()
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        print("[WatchConnectivity] activationDidComplete state=\(activationState.rawValue) error=\(String(describing: error))")
        let existingContext = session.receivedApplicationContext
        if !existingContext.isEmpty {
            print("[WatchConnectivity] existing receivedApplicationContext: \(existingContext)")
            handleCredentialPayload(existingContext)
        }
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            self.lastErrorMessage = error?.localizedDescription
            self.hasAccessToken = self.tokenStore.readAccessToken() != nil
        }
    }

    #if os(watchOS)
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("[WatchConnectivity] reachability changed: \(session.isReachable)")
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("[WatchConnectivity] didReceiveMessage: \(message)")
        handleCredentialPayload(message)
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        print("[WatchConnectivity] didReceiveMessage with reply: \(message)")
        handleCredentialPayload(message)
        replyHandler(["status": "ok"])
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("[WatchConnectivity] didReceiveApplicationContext: \(applicationContext)")
        handleCredentialPayload(applicationContext)
    }
    #endif

    private func handleCredentialPayload(_ message: [String: Any]) {
        print("[WatchConnectivity] handleCredentialPayload action=\(String(describing: message["action"]))")
        guard let action = message["action"] as? String else { return }
        guard action == "setWatchAccessToken" else { return }
        guard let accessToken = message["accessToken"] as? String, !accessToken.isEmpty else {
            DispatchQueue.main.async {
                self.lastErrorMessage = "토큰이 비어 있습니다."
            }
            return
        }
        do {
            try tokenStore.saveAccessToken(accessToken)
            print("[WatchConnectivity] access token saved. prefix=\(accessToken.prefix(12))...")
            DispatchQueue.main.async {
                self.lastErrorMessage = nil
                self.hasAccessToken = true
            }
        } catch {
            DispatchQueue.main.async {
                self.lastErrorMessage = "토큰 저장 실패: \(error.localizedDescription)"
            }
        }
    }
}

struct WatchTokenStore {
    private let service = "com.kdh.mobile.watch"
    private let account = "watch_access_token"

    func saveAccessToken(_ token: String) throws {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else { throw NSError(domain: NSOSStatusErrorDomain, code: Int(status)) }
    }

    func readAccessToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        guard let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
#endif
