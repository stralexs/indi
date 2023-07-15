//
//  SettingsAndStatisticsViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import Foundation
import UIKit

final class SettingsAndStatisticsViewModel {
    //MARK: - Private Variables
    private var defaultAvatars: [UIImage] = {
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
    }()
    
    private var userStatistics: [String: String] = [
        "Пройдено тестов": "\(UserDataManager.shared.getUserStatistics().tests)",
        "Сдано экзаменов": "\(UserDataManager.shared.getUserStatistics().exams)",
        "Количество правильных ответов": "\(UserDataManager.shared.getUserStatistics().correct)",
        "Процент правильных ответов": "\(UserDataManager.shared.getUserStatistics().percentage)%"
    ]

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
    //MARK: - Public Variables
    var userStatisticsCount: Int {
        return userStatistics.count
    }
    var userClickedToChangeAvatar: Bool = false
    var resetAchievements: Bool = false
    
    //MARK: - Private Method
    private func removingSpaces(for text: String) -> String {
        var outputText = text
        
        while outputText.first == " " {
            outputText.removeFirst()
        }
        while outputText.last == " " {
            outputText.removeLast()
        }
        
        return outputText
    }
    
    //MARK: - Public Methods
    func applyChanges(for nameTexFieldText: String, and middleAvatarImageName: String) -> String {
        var output = ""
        var countOfChanges = 0

        let nameWithoutSpaces = removingSpaces(for: nameTexFieldText)
        
        if nameWithoutSpaces == "" {
            output = "Empty name"
        } else if nameWithoutSpaces.count > 15 {
            output = "Too long name"
        } else if UserDataManager.shared.getUserName() != nameWithoutSpaces {
            UserDataManager.shared.saveUserName(for: nameWithoutSpaces)
            countOfChanges += 1
        }
        
        if resetAchievements {
            UserDataManager.shared.resetAchievements()
            countOfChanges += 1
        }
        
        let currentUserAvatar = UserDataManager.shared.getUserAvatar()
        if userClickedToChangeAvatar && middleAvatarImageName != currentUserAvatar {
            UserDataManager.shared.saveUserAvatar(for: middleAvatarImageName)
            countOfChanges += 1
        }
        
        if countOfChanges != 0 {
            output = "Changes saved"
        }
        
        return output
    }
    
    func getUserStatisticsInfo(for position: Int) -> (String, String) {
        var count = 0
        var output = ("", "")
        for (key, value) in userStatistics {
            if count == position {
                output = (key, value)
            }
            count += 1
        }
        return output
    }
    
    func avatarSwipe(_ isLeftButton: Bool) -> (UIImage, UIImage, UIImage) {
        if isLeftButton {
            leftAvatarIndex += 1
            middleAvatarIndex += 1
            rightAvatarIndex += 1
        } else {
            leftAvatarIndex -= 1
            middleAvatarIndex -= 1
            rightAvatarIndex -= 1
        }
        return (defaultAvatars[leftAvatarIndex], defaultAvatars[middleAvatarIndex], defaultAvatars[rightAvatarIndex])
    }
}
