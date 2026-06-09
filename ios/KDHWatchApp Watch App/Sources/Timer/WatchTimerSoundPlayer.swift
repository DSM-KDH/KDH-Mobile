#if os(watchOS)
import AVFoundation
import Combine

@MainActor
final class WatchTimerSoundPlayer: ObservableObject {
    private var players: [String: AVAudioPlayer] = [:]

    init(soundNames: [String]) {
        soundNames.forEach { loadSound(named: $0) }
    }

    func play(_ name: String) {
        guard let player = players[name] else { return }
        player.currentTime = 0
        player.play()
    }

    func stopAll() {
        players.values.forEach { player in
            player.stop()
            player.currentTime = 0
        }
    }

    private func loadSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[name] = player
        } catch {
            #if DEBUG
            print("[WatchSound] failed to load \(name).mp3: \(error)")
            #endif
        }
    }
}
#endif
