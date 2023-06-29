//
//  LocalNotificationsManager.swift
//  Indi
//
//  Created by Alexander Sivko on 28.05.23.
//

import Foundation
import UserNotifications

class LocalNotificationsManager {
    let notificationCenter = UNUserNotificationCenter.current()
    
    private func notificationSetup() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else { return }
            self.notificationCenter.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
            }
        }
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = randomTitleGenerator()
        content.body = bodyGenerator()
        content.sound = UNNotificationSound.default
        
        let dateComponents = DateComponents(calendar: .current, timeZone: .current, hour: 12, minute: 30)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "notification", content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
    
    private func randomTitleGenerator() -> String {
        let first = "Пора узнать новые слова!"
        let second = "Время английского!"
        let third = "English time!"
        let fourth = "Got tests?"
        
        let titlesArr = [first, second, third, fourth]
        
        return titlesArr.randomElement()!
    }
    
    private func bodyGenerator() -> String {
        var completionInfo: [String] = []
        (0...4).forEach { num in
            completionInfo.append(UserDataManager.shared.getExamCompletion(for: num))
        }
        let currentStage = completionInfo.firstIndex(of: "Uncompleted")
        
        var kitsNames: [String] = []
        var examName = ""
        
        switch currentStage {
        case 0:
            kitsNames = KitsManager.shared.getKitNamesForStudyStage(with: [0])
            examName = StudyStage.getExamName(studyStage: 0)
        case 1:
            kitsNames = KitsManager.shared.getKitNamesForStudyStage(with: [1])
            examName = StudyStage.getExamName(studyStage: 1)
        case 2:
            kitsNames = KitsManager.shared.getKitNamesForStudyStage(with: [2])
            examName = StudyStage.getExamName(studyStage: 2)
        case 3:
            kitsNames = KitsManager.shared.getKitNamesForStudyStage(with: [3,4])
            examName = StudyStage.getExamName(studyStage: 3)
        case 4:
            kitsNames = KitsManager.shared.getKitNamesForStudyStage(with: UserDataManager.shared.getSelectedStages())
            examName = StudyStage.getExamName(studyStage: 4)
        default:
            kitsNames = []
            examName = "None"
        }
                
        var userResults: [Int] = []
        kitsNames.forEach { name in
            userResults.append(UserDataManager.shared.getUserResult(for: name))
        }
        let unsolvedTestsCount = userResults.filter { $0 < 70 }.count
        
        var output = ""
        let name = UserDataManager.shared.getUserName()
        
        if unsolvedTestsCount == 0 && examName == "None" {
            output = "\(name), может выполним все тесты на 100%? Или начнём новую игру?"
        } else if unsolvedTestsCount == 0 {
            output = "\(name), пора выполнить \(examName)!"
        } else {
            switch unsolvedTestsCount {
            case 1:
                output = "\(name), пройдите оставшийся тест для экзамена, остался всего \(unsolvedTestsCount)!"
            default:
                output = "\(name), пройдите оставшиеся тесты для экзамена, осталось всего \(unsolvedTestsCount)!"
            }
        }
        
        return output
    }
    
    init() {
        notificationSetup()
    }
}
