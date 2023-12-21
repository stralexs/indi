//
//  SettingsAndStatisticsViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import RxSwift
import RxCocoa

protocol SettingsAndStatisticsViewModelData {
    var leftAvatarImage: BehaviorRelay<UIImage> { get }
    var middleAvatarImage: BehaviorRelay<UIImage> { get }
    var rightAvatarImage: BehaviorRelay<UIImage> { get }
    var userStatisticsCount: Int { get }
    var userName: String { get }
    var isUserClickedToChangeAvatar: Bool { get set }
    var isSetResetAchievements: Bool { get set }
}

protocol SettingsAndStatisticsViewModelLogic {
    func applyChanges(for nameTexFieldText: String, and middleAvatarImageName: String) throws
    func getUserStatisticsInfo(for position: Int) -> (String, String)
    func avatarSwipe(_ isLeftButton: Bool)
}

fileprivate extension Int {
    mutating func limitToRange() {
        if self > 3 {
            self = 0
        } else if self < 0 {
            self = 3
        }
    }
}

fileprivate extension UIImage {
    static let cat = UIImage(named: "Cat_emoji") ?? UIImage()
    static let dog = UIImage(named: "Dog_emoji") ?? UIImage()
    static let man = UIImage(named: "Man_emoji") ?? UIImage()
    static let woman = UIImage(named: "Woman_emoji") ?? UIImage()
}

final class SettingsAndStatisticsViewModel: SettingsAndStatisticsViewModelData {
    private let defaultAvatars = [UIImage.cat, UIImage.dog, UIImage.man, UIImage.woman]
    private let userStatistics: [String: String] = [
        "Пройдено тестов": "\(UserDataManager.shared.getUserStatistics().tests)",
        "Сдано экзаменов": "\(UserDataManager.shared.getUserStatistics().exams)",
        "Количество правильных ответов": "\(UserDataManager.shared.getUserStatistics().correct)",
        "Процент правильных ответов": "\(UserDataManager.shared.getUserStatistics().percentage)%"
    ]

    private var leftAvatarIndex = 3
    private var middleAvatarIndex = 0
    private var rightAvatarIndex = 1
    
    let leftAvatarImage: BehaviorRelay<UIImage> = BehaviorRelay(value: UIImage.woman)
    let middleAvatarImage: BehaviorRelay<UIImage> = BehaviorRelay(value: UIImage.cat)
    let rightAvatarImage: BehaviorRelay<UIImage> = BehaviorRelay(value: UIImage.man)
    
    var userStatisticsCount: Int { userStatistics.count }
    var userName: String { UserDataManager.shared.userNameAndAvatar.value["UserName"] ?? "UserName" }
    var isUserClickedToChangeAvatar = Bool()
    var isSetResetAchievements = Bool()
}

extension SettingsAndStatisticsViewModel: SettingsAndStatisticsViewModelLogic {
    func applyChanges(for nameTexFieldText: String, and middleAvatarImageName: String) throws {
        var countOfChanges = 0
        let trimmedName = nameTexFieldText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName == "" {
            throw SettingsError.emptyName
        } else if trimmedName.count > 15 {
            throw SettingsError.tooLongName
        } else if UserDataManager.shared.userNameAndAvatar.value["UserName"] ?? "UserName" != trimmedName {
            UserDataManager.shared.saveUserName(for: trimmedName)
            countOfChanges += 1
        }
        
        if isSetResetAchievements {
            UserDataManager.shared.resetAchievements()
            countOfChanges += 1
        }
        
        let currentUserAvatar = UserDataManager.shared.userNameAndAvatar.value["UserName"] ?? "UserName"
        if isUserClickedToChangeAvatar && middleAvatarImageName != currentUserAvatar {
            UserDataManager.shared.saveUserAvatar(for: middleAvatarImageName)
            countOfChanges += 1
        }
        
        if countOfChanges != 0 {
            throw SettingsError.changesOverZero
        }
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
    
    func avatarSwipe(_ isLeftButton: Bool) {
        let indexIncrement = 1
        if isLeftButton {
            leftAvatarIndex += indexIncrement
            middleAvatarIndex += indexIncrement
            rightAvatarIndex += indexIncrement
        } else {
            leftAvatarIndex -= indexIncrement
            middleAvatarIndex -= indexIncrement
            rightAvatarIndex -= indexIncrement
        }
        
        leftAvatarIndex.limitToRange()
        middleAvatarIndex.limitToRange()
        rightAvatarIndex.limitToRange()
        
        leftAvatarImage.accept(defaultAvatars[leftAvatarIndex])
        middleAvatarImage.accept(defaultAvatars[middleAvatarIndex])
        rightAvatarImage.accept(defaultAvatars[rightAvatarIndex])
    }
}
