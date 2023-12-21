//
//  LocalNotificationsManager.swift
//  Indi
//
//  Created by Alexander Sivko on 28.05.23.
//

import UserNotifications

final class LocalNotificationsManager {
    private let notificationCenter = UNUserNotificationCenter.current()
    
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
        let firstTitleVariant = "Пора узнать новые слова!"
        let secondTitleVariant = "Время английского!"
        let thirdTitleVariant = "English time!"
        let fourthTitleVariant = "Got tests?"
        
        let titlesArr = [firstTitleVariant, secondTitleVariant, thirdTitleVariant, fourthTitleVariant]
        
        return titlesArr.randomElement()!
    }
    
    private func getExamName(_ studyStages: [Int]) -> [String] {
        return studyStages.map { studyStage in
            return KitsManager.shared.kits.value.filter { $0.studyStage == studyStage }
        }
            .flatMap { $0 }
            .map { $0.name ?? "" }
    }
    
    private func bodyGenerator() -> String {
        let completionInfo = (0...4).map { UserDataManager.shared.stagesCompletionAndSelection.value["\($0)"] ?? "Uncompleted" }
        let currentStage = completionInfo.firstIndex(of: "Uncompleted")
        
        var kitsNames = [String]()
        var examName = ""
        
        switch currentStage {
        case 0:
            kitsNames = getExamName([0])
            examName = StudyStage.getExamName(studyStage: 0)
        case 1:
            kitsNames = getExamName([1])
            examName = StudyStage.getExamName(studyStage: 1)
        case 2:
            kitsNames = getExamName([2])
            examName = StudyStage.getExamName(studyStage: 2)
        case 3:
            kitsNames = getExamName([3,4])
            examName = StudyStage.getExamName(studyStage: 3)
        case 4:
            kitsNames = getExamName(UserDataManager.shared.getSelectedStages())
            examName = StudyStage.getExamName(studyStage: 4)
        default:
            kitsNames = []
            examName = "None"
        }
                
        let userResults = kitsNames.map { UserDataManager.shared.userResults.value[$0] ?? 0 }
        let unsolvedTestsCount = userResults.filter { $0 < 70 }.count
        
        var output = ""
        let name = UserDataManager.shared.userNameAndAvatar.value["UserName"] ?? "UserName"
        
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
