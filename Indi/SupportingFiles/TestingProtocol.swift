//
//  TestingProtocol.swift
//  Indi
//
//  Created by Alexander Sivko on 30.05.23.
//

import Foundation
import UIKit

protocol Testing {
    var userAnswer: String? { get set }
    
    func testStart()
    func test(questionLabel UILabel: UILabel?, buttons UIButtons: [UIButton]?, countLabel UILabel: UILabel?)
    func isRightAnswerCheck() -> Bool
    func nextQuestion()
    func resetResults()
}
