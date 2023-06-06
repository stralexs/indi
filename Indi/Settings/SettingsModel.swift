//
//  SettingsModel.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import Foundation
import UIKit

class SettingsModel {   
    var userAge = 0
    
    private var defaultAvatars: [UIImage] = []
    
    private func createAvatars() -> [UIImage] {
        var tempArr = [UIImage]()
        
        let cat = UIImage(named: "Cat_emoji")
        let dog = UIImage(named: "Dog_emoji")
        let man = UIImage(named: "Man_emoji")
        let woman = UIImage(named: "Woman_emoji")
        
        tempArr.append(cat!)
        tempArr.append(dog!)
        tempArr.append(man!)
        tempArr.append(woman!)
        
        return tempArr
    }
    
    enum Avatar {
        case left
        case middle
        case right
    }
    
    private var leftAvatarIndex = 3 {
        didSet {
            if leftAvatarIndex > 3 {
                leftAvatarIndex = 0
            }
            if leftAvatarIndex < 0 {
                leftAvatarIndex = 3
            }
        }
    }
    private var middleAvatarIndex = 0 {
        didSet {
            if middleAvatarIndex > 3 {
                middleAvatarIndex = 0
            }
            if middleAvatarIndex < 0 {
                middleAvatarIndex = 3
            }
        }
    }
    private var rightAvatarIndex = 1 {
        didSet {
            if rightAvatarIndex > 3 {
                rightAvatarIndex = 0
            }
            if rightAvatarIndex < 0 {
                rightAvatarIndex = 3
            }
        }
    }
    
    func avatarSelection(_ isLeftButton: Bool, with position: Avatar) -> UIImage {
        var outputImage = UIImage()
        
        if isLeftButton {
            switch position {
            case .left:
                leftAvatarIndex += 1
                outputImage = defaultAvatars[leftAvatarIndex]
            case .middle:
                middleAvatarIndex += 1
                outputImage = defaultAvatars[middleAvatarIndex]
            case .right:
                rightAvatarIndex += 1
                outputImage = defaultAvatars[rightAvatarIndex]
            }
        } else {
            switch position {
            case .left:
                leftAvatarIndex -= 1
                outputImage = defaultAvatars[leftAvatarIndex]
            case .middle:
                middleAvatarIndex -= 1
                outputImage = defaultAvatars[middleAvatarIndex]
            case .right:
                rightAvatarIndex -= 1
                outputImage = defaultAvatars[rightAvatarIndex]
            }
        }

        return outputImage
    }
    
    init() {
        defaultAvatars = createAvatars()
    }
}
