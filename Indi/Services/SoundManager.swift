//
//  SoundManager.swift
//  Indi
//
//  Created by Alexander Sivko on 29.06.23.
//

import AVFoundation

protocol SoundManagerProtocol {
    func playCorrectSound()
    func playWrongSound()
}

final class SoundManager: SoundManagerProtocol {
    private var player = AVAudioPlayer()

    func playCorrectSound() {
        let soundUrl = Bundle.main.url(forResource: "Correct-answer-sound", withExtension: "mp3")
        do {
            player = try AVAudioPlayer(contentsOf: soundUrl!)
            player.volume = 2
            DispatchQueue.global().async {
                self.player.play()
            }
        }
        catch {
            print(error)
        }
    }
    
    func playWrongSound() {
        let soundUrl = Bundle.main.url(forResource: "Wrong-answer-sound", withExtension: "mp3")
        do {
            player = try AVAudioPlayer(contentsOf: soundUrl!)
            player.volume = 6
            DispatchQueue.global().async {
                self.player.play()
            }
        }
        catch {
            print(error)
        }
    }
    
    init() { player.prepareToPlay() }
}
