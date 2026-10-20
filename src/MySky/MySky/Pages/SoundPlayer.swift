//
//  SoundPlayer.swift
//  MySky
//
//  Created by Lika Nozadze on 20/10/2026.
//

import AVFoundation

final class SoundPlayer {
    static let shared = SoundPlayer()

    private var players: [String: AVAudioPlayer] = [:]
    private let queue = DispatchQueue(label: "SoundPlayer", qos: .userInitiated)

    private init() {
        queue.async {
            try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        }
    }

    func preload(_ name: String, ext: String = "mp3") {
        queue.async { _ = self.player(for: name, ext: ext) }
    }

    func play(_ name: String, ext: String = "mp3", volume: Float = 0.8, loop: Bool = false) {
        queue.async {
            guard let player = self.player(for: name, ext: ext) else { return }
            player.volume = volume
            player.numberOfLoops = loop ? -1 : 0
            player.currentTime = 0
            player.play()
        }
    }

    func stop(_ name: String) {
        queue.async { self.players[name]?.stop() }
    }


    private func player(for name: String, ext: String) -> AVAudioPlayer? {
        if let existing = players[name] { return existing }
        guard let url = Bundle.main.url(forResource: name, withExtension: ext),
              let player = try? AVAudioPlayer(contentsOf: url) else {
            print("Sound not found: \(name).\(ext)")
            return nil
        }
        player.prepareToPlay()
        players[name] = player
        return player
    }
}
