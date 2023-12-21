//
//  SoundManager.swift
//  Indi
//
//  Created by Alexander Sivko on 29.06.23.
//

import AVFoundation
import OSLog

protocol SoundManagerLogic {
    func playCorrectSound()
    func playWrongSound()
}

final class SoundManager: SoundManagerLogic {
    private var correctSoundPlayer = AVAudioPlayer()
    private var wrongSoundPlayer = AVAudioPlayer()
    private let logger = Logger()

    func playCorrectSound() {
        correctSoundPlayer.play()
    }
    
    func playWrongSound() {
        wrongSoundPlayer.play()
    }
    
    init() {
        createCorrectSoundPlayer { [weak self] player in
            self?.correctSoundPlayer = player
        }
        createWrongSoundPlayer { [weak self] player in
            self?.wrongSoundPlayer = player
        }
    }
}

extension SoundManager {
    private func createCorrectSoundPlayer(completion: @escaping (AVAudioPlayer) -> Void) {
        DispatchQueue.global().async {
            guard let soundUrl = Bundle.main.url(forResource: "Correct-answer-sound", withExtension: "mp3") else { return completion(AVAudioPlayer()) }
            var player = AVAudioPlayer()
            do {
                player = try AVAudioPlayer(contentsOf: soundUrl)
                player.volume = 2
                player.prepareToPlay()
                completion(player)
            }
            catch {
                self.logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    private func createWrongSoundPlayer(completion: @escaping (AVAudioPlayer) -> Void) {
        DispatchQueue.global().async {
            guard let soundUrl = Bundle.main.url(forResource: "Wrong-answer-sound", withExtension: "mp3") else { return completion(AVAudioPlayer()) }
            var player = AVAudioPlayer()
            do {
                player = try AVAudioPlayer(contentsOf: soundUrl)
                player.volume = 6
                player.prepareToPlay()
                completion(player)
            }
            catch {
                self.logger.error("\(error.localizedDescription)")
            }
        }
    }
}
