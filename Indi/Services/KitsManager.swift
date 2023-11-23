//
//  KitsManager.swift
//  Indi
//
//  Created by Alexander Sivko on 1.05.23.
//

import CoreData
import RxSwift
import RxCocoa
import OSLog

protocol KitsManagerData {
    var kits: BehaviorRelay<[Kit]> { get }
}

protocol KitsManagerLogic {
    func createQuestionWithoutSaving(_ question: String, _ correctAnswer: String, _ incorrectAnswers: [String]) -> Question
    func createNewKit(_ kitName: String, _ studyStage: Int, _ questions: [Question])
    func isBasicKitCheck(for indexPath: IndexPath, for studyStageRawValue: Int) -> Bool
    func deleteUserKit(for indexPath: IndexPath, for studyStageRawValue: Int)
}

final class KitsManager: KitsManagerData {
    static let shared = KitsManager()
    private init() {
        coreDataManager = CoreDataManager()
        fetchKits()
    }
    
    private let logger = Logger()
    private let coreDataManager: CoreDataManagerDataAndLogic
    let kits: BehaviorRelay<[Kit]> = BehaviorRelay(value: [])
}

extension KitsManager: KitsManagerLogic {
    func createQuestionWithoutSaving(_ question: String, _ correctAnswer: String, _ incorrectAnswers: [String]) -> Question {
        let newQuestion = Question(context: coreDataManager.context)
        newQuestion.question = question
        newQuestion.correctAnswer = correctAnswer
        newQuestion.incorrectAnswers = incorrectAnswers
        return newQuestion
    }
    
    func createNewKit(_ kitName: String, _ studyStage: Int, _ questions: [Question]) {
        let newKit = Kit(context: coreDataManager.context)
        newKit.studyStage = Int64(studyStage)
        newKit.questions = newKit.questions?.addingObjects(from: questions) as NSSet?
        newKit.name = kitName
        newKit.isBasicKit = false
        kits.accept(kits.value + [newKit])
        save()
    }
    
    func isBasicKitCheck(for indexPath: IndexPath, for studyStageRawValue: Int) -> Bool {
        var selectedKit = Kit()
        do {
            let fetchRequest = basicFetch(studyStage: studyStageRawValue)
            selectedKit = try coreDataManager.context.fetch(fetchRequest)[indexPath.row]
        }
        catch {
            logger.error("\(error.localizedDescription)")
        }
        return selectedKit.isBasicKit
    }
    
    func deleteUserKit(for indexPath: IndexPath, for studyStageRawValue: Int) {
        do {
            let fetchRequest = basicFetch(studyStage: studyStageRawValue)
            let selectedKit = try coreDataManager.context.fetch(fetchRequest)[indexPath.row]
            coreDataManager.context.delete(selectedKit)
            
            let questionsRequest = Question.fetchRequest()
            let _ = try coreDataManager.context.fetch(questionsRequest)
                .filter { $0.kit == nil }
                .map { coreDataManager.context.delete($0) }
            
            var kits = kits.value
            kits.removeAll(where: { $0.name == selectedKit.name })
            self.kits.accept(kits)
        }
        catch {
            logger.error("\(error.localizedDescription)")
        }
        save()
    }
}

    // MARK: - Private logic
extension KitsManager {
    private func fetchKits() {
        let fetchRequest = Kit.fetchRequest()
        let sortByStudyStage = NSSortDescriptor(key: "studyStage", ascending: true)
        fetchRequest.sortDescriptors = [sortByStudyStage]
        
        do {
            let kits = try coreDataManager.context.fetch(fetchRequest)
            if kits.isEmpty {
                createKits()
                fetchKits()
            } else {
                self.kits.accept(kits)
            }
        }
        catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    private func basicFetch(studyStage rawValue: Int) -> NSFetchRequest<Kit> {
        let fetchRequest = Kit.fetchRequest()
        let predicate = NSPredicate(format: "studyStage = %d", rawValue)
        fetchRequest.predicate = predicate
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        return fetchRequest
    }
     
    private func save() {
        coreDataManager.save { error in
            guard let error = error else { return }
            logger.error("\(error.localizedDescription)")
        }
    }
}

    // MARK: - Kits creation
extension KitsManager {
    private func createKits() {
        // MARK: Newborn Kits
        let mother = Question(context: coreDataManager.context)
        mother.question = "Мама"
        mother.correctAnswer = "Mother"
        mother.incorrectAnswers = ["Father", "Grandmother", "Grandfather"]
        let father = Question(context: coreDataManager.context)
        father.question = "Папа"
        father.correctAnswer = "Father"
        father.incorrectAnswers = ["Mother", "Grandmother", "Grandfather"]
        let iLoveYou = Question(context: coreDataManager.context)
        iLoveYou.question = "Я тебя люблю"
        iLoveYou.correctAnswer = "I love you"
        iLoveYou.incorrectAnswers = ["I love me", "Love I you", "I luv u"]
        let he = Question(context: coreDataManager.context)
        he.question = "Он"
        he.correctAnswer = "He"
        he.incorrectAnswers = ["She", "Me", "We"]
        let she = Question(context: coreDataManager.context)
        she.question = "Она"
        she.correctAnswer = "She"
        she.incorrectAnswers = ["He", "Me", "They"]
        let it = Question(context: coreDataManager.context)
        it.question = "Оно"
        it.correctAnswer = "It"
        it.incorrectAnswers = ["She", "He", "They"]
        let car = Question(context: coreDataManager.context)
        car.question = "Машина"
        car.correctAnswer = "Car"
        car.incorrectAnswers = ["Bus", "Apple", "Chicken"]
        let house = Question(context: coreDataManager.context)
        house.question = "Дом"
        house.correctAnswer = "House"
        house.incorrectAnswers = ["Car", "Grandmother", "Ball"]
        let ball = Question(context: coreDataManager.context)
        ball.question = "Мяч"
        ball.correctAnswer = "Ball"
        ball.incorrectAnswers = ["Cube", "Dog", "Grass"]
        let table = Question(context: coreDataManager.context)
        table.question = "Cтол"
        table.correctAnswer = "Table"
        table.incorrectAnswers = ["Chair", "Bed", "Lamp"]
           
        let newbornBasicWordsKit = Kit(context: coreDataManager.context)
        newbornBasicWordsKit.studyStage = StudyStage.newborn.rawValue
        newbornBasicWordsKit.questions = [mother, father, iLoveYou, he, she, it, car, house, ball, table]
        newbornBasicWordsKit.name = "Basic words"
        newbornBasicWordsKit.isBasicKit = true
        
        let blue = Question(context: coreDataManager.context)
        blue.question = "Cиний"
        blue.correctAnswer = "Blue"
        blue.incorrectAnswers = ["Red", "Yellow", "Green"]
        let red = Question(context: coreDataManager.context)
        red.question = "Красный"
        red.correctAnswer = "Red"
        red.incorrectAnswers = ["Blue", "Green", "Orange"]
        let green = Question(context: coreDataManager.context)
        green.question = "Зелёный"
        green.correctAnswer = "Green"
        green.incorrectAnswers = ["Blue", "Purple", "Orange"]
        let yellow = Question(context: coreDataManager.context)
        yellow.question = "Жёлтый"
        yellow.correctAnswer = "Yellow"
        yellow.incorrectAnswers = ["Red", "Blue", "Green"]
        let orange = Question(context: coreDataManager.context)
        orange.question = "Оранжевый"
        orange.correctAnswer = "Orange"
        orange.incorrectAnswers = ["Red", "Green", "Mouse"]
        let purple = Question(context: coreDataManager.context)
        purple.question = "Фиолетовый"
        purple.correctAnswer = "Purple"
        purple.incorrectAnswers = ["Pink", "Yellow", "Red"]
        let pink = Question(context: coreDataManager.context)
        pink.question = "Розовый"
        pink.correctAnswer = "Pink"
        pink.incorrectAnswers = ["Yellow", "Blue", "Green"]
        let black = Question(context: coreDataManager.context)
        black.question = "Чёрный"
        black.correctAnswer = "Black"
        black.incorrectAnswers = ["White", "Green", "Yellow"]
        let white = Question(context: coreDataManager.context)
        white.question = "Белый"
        white.correctAnswer = "White"
        white.incorrectAnswers = ["Black", "Blue", "Green"]
        
        let newbornBasicColorsKit = Kit(context: coreDataManager.context)
        newbornBasicColorsKit.studyStage = StudyStage.newborn.rawValue
        newbornBasicColorsKit.questions = [blue, red, green, yellow, orange, purple, pink, black, white]
        newbornBasicColorsKit.name = "Basic colors"
        newbornBasicColorsKit.isBasicKit = true
        
        let cat = Question(context: coreDataManager.context)
        cat.question = "Кот"
        cat.correctAnswer = "Cat"
        cat.incorrectAnswers = ["Dog", "Hamster", "Car"]
        let dog = Question(context: coreDataManager.context)
        dog.question = "Собака"
        dog.correctAnswer = "Dog"
        dog.incorrectAnswers = ["Cat", "Mother", "Bus"]
        let cow = Question(context: coreDataManager.context)
        cow.question = "Корова"
        cow.correctAnswer = "Cow"
        cow.incorrectAnswers = ["Dog", "Chicken", "Chair"]
        let hen = Question(context: coreDataManager.context)
        hen.question = "Курица"
        hen.correctAnswer = "Hen"
        hen.incorrectAnswers = ["Rooster", "Dog", "Chick"]
        let horse = Question(context: coreDataManager.context)
        horse.question = "Лошадь"
        horse.correctAnswer = "Horse"
        horse.incorrectAnswers = ["Pig", "Chicken", "Duck"]
        let pig = Question(context: coreDataManager.context)
        pig.question = "Свинья"
        pig.correctAnswer = "Pig"
        pig.incorrectAnswers = ["Horse", "Dog", "Duck"]
        let mouse = Question(context: coreDataManager.context)
        mouse.question = "Мышь"
        mouse.correctAnswer = "Mouse"
        mouse.incorrectAnswers = ["Rat", "Mice", "Dog"]
        let duck = Question(context: coreDataManager.context)
        duck.question = "Утка"
        duck.correctAnswer = "Duck"
        duck.incorrectAnswers = ["Hen", "Rooster", "Mouse"]
        let goose = Question(context: coreDataManager.context)
        goose.question = "Гусь"
        goose.correctAnswer = "Goose"
        goose.incorrectAnswers = ["Chicken", "Horse", "Pig"]
        let sheep = Question(context: coreDataManager.context)
        sheep.question = "Овца"
        sheep.correctAnswer = "Sheep"
        sheep.incorrectAnswers = ["Dog", "Goose", "Rooster"]
        
        let newbornFarmAnimalsKit = Kit(context: coreDataManager.context)
        newbornFarmAnimalsKit.studyStage = StudyStage.newborn.rawValue
        newbornFarmAnimalsKit.questions = [cat, dog, cow, hen, horse, pig, mouse, duck, goose, sheep]
        newbornFarmAnimalsKit.name = "Farm animals"
        newbornFarmAnimalsKit.isBasicKit = true
        
        // MARK: Preschool Kits
        let missingB = Question(context: coreDataManager.context)
        missingB.question = "A, _, C, D"
        missingB.correctAnswer = "B"
        missingB.incorrectAnswers = ["F", "C", "G"]
        let missingY = Question(context: coreDataManager.context)
        missingY.question = "W, X, _, Z"
        missingY.correctAnswer = "Y"
        missingY.incorrectAnswers = ["X", "Q", "S"]
        let missingO = Question(context: coreDataManager.context)
        missingO.question = "L, M, N, _"
        missingO.correctAnswer = "O"
        missingO.incorrectAnswers = ["P", "Q", "B"]
        let missingF = Question(context: coreDataManager.context)
        missingF.question = "_, G, H, I"
        missingF.correctAnswer = "F"
        missingF.incorrectAnswers = ["D", "E", "Y"]
        let missingQ = Question(context: coreDataManager.context)
        missingQ.question = "P, _, R, S"
        missingQ.correctAnswer = "Q"
        missingQ.incorrectAnswers = ["Y", "U", "W"]
        let missingD = Question(context: coreDataManager.context)
        missingD.question = "_, E, F, G"
        missingD.correctAnswer = "D"
        missingD.incorrectAnswers = ["E", "C", "X"]
        let missingR = Question(context: coreDataManager.context)
        missingR.question = "P, Q, _, S"
        missingR.correctAnswer = "R"
        missingR.incorrectAnswers = ["M", "Y", "Z"]
        let missingN = Question(context: coreDataManager.context)
        missingN.question = "K, L, M, _"
        missingN.correctAnswer = "N"
        missingN.incorrectAnswers = ["O", "Q", "A"]
        let missingG = Question(context: coreDataManager.context)
        missingG.question = "_, H, I, J"
        missingG.correctAnswer = "G"
        missingG.incorrectAnswers = ["A", "Y", "W"]
        let missingI = Question(context: coreDataManager.context)
        missingI.question = "H, _, J, K"
        missingI.correctAnswer = "I"
        missingI.incorrectAnswers = ["Y", "K", "E"]
        
        let preschoolBasicAlphabet = Kit(context: coreDataManager.context)
        preschoolBasicAlphabet.studyStage = StudyStage.preschool.rawValue
        preschoolBasicAlphabet.questions = [missingB, missingY, missingO, missingF, missingQ, missingD, missingR, missingN, missingG, missingI]
        preschoolBasicAlphabet.name = "Basic alphabet"
        preschoolBasicAlphabet.isBasicKit = true
        
        let hand = Question(context: coreDataManager.context)
        hand.question = "Ладонь"
        hand.correctAnswer = "Palm"
        hand.incorrectAnswers = ["Mouth", "Hand", "Head"]
        let nose = Question(context: coreDataManager.context)
        nose.question = "Нос"
        nose.correctAnswer = "Nose"
        nose.incorrectAnswers = ["Hand", "Ear", "Legs"]
        let head = Question(context: coreDataManager.context)
        head.question = "Голова"
        head.correctAnswer = "Head"
        head.incorrectAnswers = ["Banana", "Eye", "Hair"]
        let neck = Question(context: coreDataManager.context)
        neck.question = "Шея"
        neck.correctAnswer = "Neck"
        neck.incorrectAnswers = ["Head", "Eye", "Cheek"]
        let cheek = Question(context: coreDataManager.context)
        cheek.question = "Щека"
        cheek.correctAnswer = "Cheek"
        cheek.incorrectAnswers = ["Belly", "Mouth", "Ear"]
        let ear = Question(context: coreDataManager.context)
        ear.question = "Ухо"
        ear.correctAnswer = "Ear"
        ear.incorrectAnswers = ["Mouth", "Head", "Heel"]
        let shoulder = Question(context: coreDataManager.context)
        shoulder.question = "Плечо"
        shoulder.correctAnswer = "Shoulder"
        shoulder.incorrectAnswers = ["Mouth", "Elbow", "Arm"]
        let arm = Question(context: coreDataManager.context)
        arm.question = "Рука"
        arm.correctAnswer = "Arm"
        arm.incorrectAnswers = ["Leg", "Hair", "Foot"]
        let finger = Question(context: coreDataManager.context)
        finger.question = "Палец"
        finger.correctAnswer = "Finger"
        finger.incorrectAnswers = ["Elbow", "Arm", "Hand"]
        let mouth = Question(context: coreDataManager.context)
        mouth.question = "Рот"
        mouth.correctAnswer = "Mouth"
        mouth.incorrectAnswers = ["Nose", "Throat", "Ear"]
        
        let preschoolBodyParts = Kit(context: coreDataManager.context)
        preschoolBodyParts.studyStage = StudyStage.preschool.rawValue
        preschoolBodyParts.questions = [hand, nose, head, neck, cheek, ear, shoulder, arm, finger, mouth]
        preschoolBodyParts.name = "Body parts"
        preschoolBodyParts.isBasicKit = true
        
        let left = Question(context: coreDataManager.context)
        left.question = "Лево"
        left.correctAnswer = "Left"
        left.incorrectAnswers = ["Right", "Back", "Forward"]
        let right = Question(context: coreDataManager.context)
        right.question = "Право"
        right.correctAnswer = "Right"
        right.incorrectAnswers = ["Left", "Turn around", "Up"]
        let spoon = Question(context: coreDataManager.context)
        spoon.question = "Ложка"
        spoon.correctAnswer = "Spoon"
        spoon.incorrectAnswers = ["Fork", "Knife", "Plate"]
        let plate = Question(context: coreDataManager.context)
        plate.question = "Тарелка"
        plate.correctAnswer = "Plate"
        plate.incorrectAnswers = ["Fork", "Table", "Spoon"]
        let fork = Question(context: coreDataManager.context)
        fork.question = "Вилка"
        fork.correctAnswer = "Fork"
        fork.incorrectAnswers = ["Spoon", "Kettle", "Knife"]
        let knife = Question(context: coreDataManager.context)
        knife.question = "Нож"
        knife.correctAnswer = "Knife"
        knife.incorrectAnswers = ["Spoon", "Fork", "Table"]
        let please = Question(context: coreDataManager.context)
        please.question = "Пожалуйста"
        please.correctAnswer = "Please"
        please.incorrectAnswers = ["Thank you", "Goodbye", "Apple"]
        let thanks = Question(context: coreDataManager.context)
        thanks.question = "Спасибо"
        thanks.correctAnswer = "Thanks"
        thanks.incorrectAnswers = ["Please", "Goodbye", "Tanks"]
        let howOldAreYou = Question(context: coreDataManager.context)
        howOldAreYou.question = "Сколько тебе лет?"
        howOldAreYou.correctAnswer = "How old are you?"
        howOldAreYou.incorrectAnswers = ["How are you doing?", "What's the weater like today?", "How many years are you?"]
        let tea = Question(context: coreDataManager.context)
        tea.question = "Чай"
        tea.correctAnswer = "Tea"
        tea.incorrectAnswers = ["Coffee", "Cheese", "Cacao"]
        
        let preschoolBasicWords = Kit(context: coreDataManager.context)
        preschoolBasicWords.studyStage = StudyStage.preschool.rawValue
        preschoolBasicWords.questions = [left, right, spoon, plate, fork, knife, please, thanks, howOldAreYou, tea]
        preschoolBasicWords.name = "More basic words"
        preschoolBasicWords.isBasicKit = true
        
        // MARK: Early School Kits
        let twoPlusTwo = Question(context: coreDataManager.context)
        twoPlusTwo.question = "Two + two = ?"
        twoPlusTwo.correctAnswer = "Four"
        twoPlusTwo.incorrectAnswers = ["Six", "Eight", "Nine"]
        let nintySix = Question(context: coreDataManager.context)
        nintySix.question = "Девяносто шесть"
        nintySix.correctAnswer = "Ninety six"
        nintySix.incorrectAnswers = ["Ninty six", "Sixty nine", "Ninty nine"]
        let fiveHundred = Question(context: coreDataManager.context)
        fiveHundred.question = "Пятьсот"
        fiveHundred.correctAnswer = "Five hundred"
        fiveHundred.incorrectAnswers = ["Faiv hundred", "Five hundreds", "A five of hundreds"]
        let tenMinusThree = Question(context: coreDataManager.context)
        tenMinusThree.question = "Ten minus three equals ___"
        tenMinusThree.correctAnswer = "Seven"
        tenMinusThree.incorrectAnswers = ["Six", "Five", "Ten"]
        let seventyThree = Question(context: coreDataManager.context)
        seventyThree.question = "Cемьдесят три"
        seventyThree.correctAnswer = "Seventy three"
        seventyThree.incorrectAnswers = ["Seventy one", "Seventeen", "Eighty two"]
        let nineteen = Question(context: coreDataManager.context)
        nineteen.question = "Девятнадцать"
        nineteen.correctAnswer = "Nineteen"
        nineteen.incorrectAnswers = ["Nineten", "Neinteen", "Sixteen"]
        let sixPlusTen = Question(context: coreDataManager.context)
        sixPlusTen.question = "Six plus ten equals ___"
        sixPlusTen.correctAnswer = "Sixteen"
        sixPlusTen.incorrectAnswers = ["Seventeen", "Ten", "Six"]
        let equals = Question(context: coreDataManager.context)
        equals.question = "Равно"
        equals.correctAnswer = "Equals"
        equals.incorrectAnswers = ["Equlas", "Ecuals", "Isn't"]
        let threeTimesFour = Question(context: coreDataManager.context)
        threeTimesFour.question = "Three times four equals ___"
        threeTimesFour.correctAnswer = "Twelve"
        threeTimesFour.incorrectAnswers = ["Eleven", "Fourteen", "Twenty"]
        let twentyOneBySeven = Question(context: coreDataManager.context)
        twentyOneBySeven.question = "Twenty one divided by seven equals ___"
        twentyOneBySeven.correctAnswer = "Three"
        twentyOneBySeven.incorrectAnswers = ["Seven", "Two", "Six"]
        
        let earlySchoolMathsKit = Kit(context: coreDataManager.context)
        earlySchoolMathsKit.studyStage = StudyStage.earlySchool.rawValue
        earlySchoolMathsKit.questions = [twoPlusTwo, nintySix, fiveHundred, tenMinusThree, seventyThree, nineteen, sixPlusTen, equals, threeTimesFour, twentyOneBySeven]
        earlySchoolMathsKit.name = "Maths"
        earlySchoolMathsKit.isBasicKit = true
        
        let did = Question(context: coreDataManager.context)
        did.question = "Переведите предложение: Я это сделал"
        did.correctAnswer = "I did it"
        did.incorrectAnswers = ["I do it", "I want it", " I have it"]
        let pencilQuestion = Question(context: coreDataManager.context)
        pencilQuestion.question = "Переведите предложение: Я не знаю, где мой карандаш"
        pencilQuestion.correctAnswer = "I don't know where my pencil is"
        pencilQuestion.incorrectAnswers = ["I don't know where is my pencil", "Where is my pencil I don't know", "I want to know where my pencil is"]
        let pen = Question(context: coreDataManager.context)
        pen.question = "Какая часть речи у слова Pen?"
        pen.correctAnswer = "Noun"
        pen.incorrectAnswers = ["Adverb", "Adjective", "Preposition"]
        let menMultiple = Question(context: coreDataManager.context)
        menMultiple.question = "Множественное число слова Man"
        menMultiple.correctAnswer = "Men"
        menMultiple.incorrectAnswers = ["Mans", "Mens", "Woman"]
        let women = Question(context: coreDataManager.context)
        women.question = "Множественное число слова Woman"
        women.correctAnswer = "Women"
        women.incorrectAnswers = ["Womans", "Womens", "Weman"]
        let amazing = Question(context: coreDataManager.context)
        amazing.question = "Какая часть речи у слова Amazing?"
        amazing.correctAnswer = "Adjective"
        amazing.incorrectAnswers = ["Noun", "Verb", "Adverb"]
        let appleArticle = Question(context: coreDataManager.context)
        appleArticle.question = "Переведите слово Яблоко с артиклем"
        appleArticle.correctAnswer = "An apple"
        appleArticle.incorrectAnswers = ["A apple", "The peach", "A pear"]
        
        let earlySchoolBasicEnglishKit = Kit(context: coreDataManager.context)
        earlySchoolBasicEnglishKit.studyStage = StudyStage.earlySchool.rawValue
        earlySchoolBasicEnglishKit.questions = [did, pencilQuestion, pen, menMultiple, women, amazing, appleArticle]
        earlySchoolBasicEnglishKit.name = "Basic English grammar"
        earlySchoolBasicEnglishKit.isBasicKit = true
        
        // MARK: High School Kits
        let friends = Question(context: coreDataManager.context)
        friends.question = "Переведите предложение: Это дом моих друзей"
        friends.correctAnswer = "This is my friends' house"
        friends.incorrectAnswers = ["This is my friend's house", "This is my friends's house", "This is my friendss' house"]
        let whereWasBorn = Question(context: coreDataManager.context)
        whereWasBorn.question = "This is the town ____ (где) I was born in"
        whereWasBorn.correctAnswer = "Where"
        whereWasBorn.incorrectAnswers = ["When", "Which", "What"]
        let usedTo = Question(context: coreDataManager.context)
        usedTo.question = "I'm not used to ____(делать) that"
        usedTo.correctAnswer = "Do"
        usedTo.incorrectAnswers = ["Doing", "Did", "Done"]
        let summarise = Question(context: coreDataManager.context)
        summarise.question = "___ means to express the most important facts or ideas about something"
        summarise.correctAnswer = "To summarise"
        summarise.incorrectAnswers = ["To summarize", "To complete", "To launch"]
        let inOrderThat = Question(context: coreDataManager.context)
        inOrderThat.question = "(Чтобы) ___ he wouldn’t wait at the door for ages, I put the key under the mat for my new flatmate"
        inOrderThat.correctAnswer = "In order that"
        inOrderThat.incorrectAnswers = ["In view of", "In case", "On grounds of"]
        let theMost = Question(context: coreDataManager.context)
        theMost.question = "Of all the drugs that have been prescribed so far, this has proved to be ___ (самый) effective one"
        theMost.correctAnswer = "The most"
        theMost.incorrectAnswers = ["Most", "Just as", "More"]
        let whoever = Question(context: coreDataManager.context)
        whoever.question = "(Кто бы ни) ___ wins will be expected to take the rest of us for a meal"
        whoever.correctAnswer = "Whoever"
        whoever.incorrectAnswers = ["Whomever", "Whomsoever", "Who"]
        let didntThink = Question(context: coreDataManager.context)
        didntThink.question = "Before I read Freud, I (не думал) ___ dreams were of so much significance"
        didntThink.correctAnswer = "Didn't think"
        didntThink.incorrectAnswers = ["Don't think", "Wouldn't think", "Wouldn't have thought"]
        
        let highSchoolAdvancedEnglishKit = Kit(context: coreDataManager.context)
        highSchoolAdvancedEnglishKit.studyStage = StudyStage.highSchool.rawValue
        highSchoolAdvancedEnglishKit.questions = [friends, whereWasBorn, usedTo, summarise, inOrderThat, theMost, whoever, didntThink]
        highSchoolAdvancedEnglishKit.name = "Advanced English grammar"
        highSchoolAdvancedEnglishKit.isBasicKit = true
        
        let river = Question(context: coreDataManager.context)
        river.question = "Река"
        river.correctAnswer = "River"
        river.incorrectAnswers = ["Reaver", "Lake", "Stream"]
        let lake = Question(context: coreDataManager.context)
        lake.question = "Озеро"
        lake.correctAnswer = "Lake"
        lake.incorrectAnswers = ["River", "Mountain", "Rain"]
        let earth = Question(context: coreDataManager.context)
        earth.question = "Земля"
        earth.correctAnswer = "Earth"
        earth.incorrectAnswers = ["Erth", "Moon", "Planet"]
        let mountain = Question(context: coreDataManager.context)
        mountain.question = "A large natural elevation of the earth's surface"
        mountain.correctAnswer = "Mountain"
        mountain.incorrectAnswers = ["River", "Elevator", "Forest"]
        let earthsCrust = Question(context: coreDataManager.context)
        earthsCrust.question = "Земная кора"
        earthsCrust.correctAnswer = "Earth's crust"
        earthsCrust.incorrectAnswers = ["Earths' crust", "Earth's crush", "Earth's shell"]
        let ocean = Question(context: coreDataManager.context)
        ocean.question = "___ is a huge body of saltwater that covers about 71 percent of Earth’s surface"
        ocean.correctAnswer = "Ocean"
        ocean.incorrectAnswers = ["Sea", "Crust", "Salt"]
        let tide = Question(context: coreDataManager.context)
        tide.question = "Прилив"
        tide.correctAnswer = "Tide"
        tide.incorrectAnswers = ["River", "Mountain", "Volcano"]
        let migration = Question(context: coreDataManager.context)
        migration.question = "___ is relocaion of people from one region to another"
        migration.correctAnswer = "Migration"
        migration.incorrectAnswers = ["Moving", "Exchange", "Education"]
        let map = Question(context: coreDataManager.context)
        map.question = "Карта"
        map.correctAnswer = "Map"
        map.incorrectAnswers = ["Paper", "Clock", "Geography"]
        let naturalDisaster = Question(context: coreDataManager.context)
        naturalDisaster.question = "Природная катастрофа"
        naturalDisaster.correctAnswer = "Natural disaster"
        naturalDisaster.incorrectAnswers = ["Nature disaster", "Natural disastere", "Nature disastere"]
        
        let highSchoolGeographyKit = Kit(context: coreDataManager.context)
        highSchoolGeographyKit.studyStage = StudyStage.highSchool.rawValue
        highSchoolGeographyKit.questions = [river, lake, earth, mountain, earthsCrust, ocean, tide, migration, map, naturalDisaster]
        highSchoolGeographyKit.name = "Geography"
        highSchoolGeographyKit.isBasicKit = true
        
        let cell = Question(context: coreDataManager.context)
        cell.question = "Клетка"
        cell.correctAnswer = "Cell"
        cell.incorrectAnswers = ["Chamber", "Cel", "Cytoplasm"]
        let photosynthesis = Question(context: coreDataManager.context)
        photosynthesis.question = "Фотосинтез"
        photosynthesis.correctAnswer = "Photosynthesis"
        photosynthesis.incorrectAnswers = ["Photosinthesis", "Fotosynthesis", "Photosynthesys"]
        let metabolism = Question(context: coreDataManager.context)
        metabolism.question = "Обмен веществ"
        metabolism.correctAnswer = "Metabolism"
        metabolism.incorrectAnswers = ["Matter exchange", "Metabolizm", "Photosynthesis"]
        let genetics = Question(context: coreDataManager.context)
        genetics.question = "Генетика"
        genetics.correctAnswer = "Genetics"
        genetics.incorrectAnswers = ["Genetic", "Biogen", "Gens"]
        let molecule = Question(context: coreDataManager.context)
        molecule.question = "Молекула"
        molecule.correctAnswer = "Molecule"
        molecule.incorrectAnswers = ["Molecul", "Cell", "Gene"]
        let evolution = Question(context: coreDataManager.context)
        evolution.question = "Эволюция"
        evolution.correctAnswer = "Evolution"
        evolution.incorrectAnswers = ["Evolute", "Diversity", "Selection"]
        let naturalSelection = Question(context: coreDataManager.context)
        naturalSelection.question = "Естественный отбор"
        naturalSelection.correctAnswer = "Natural selection"
        naturalSelection.incorrectAnswers = ["Natural breed", "Nature selection", "Metabolism"]
        let humanBrain = Question(context: coreDataManager.context)
        humanBrain.question = "Человеческий мозг"
        humanBrain.correctAnswer = "Human brain"
        humanBrain.incorrectAnswers = ["Human cell", "Human head", "Organ"]
        let population = Question(context: coreDataManager.context)
        population.question = "Популяция"
        population.correctAnswer = "Population"
        population.incorrectAnswers = ["People", "Pupilation", "Nation"]
        let animal = Question(context: coreDataManager.context)
        animal.question = "Животное"
        animal.correctAnswer = "Animal"
        animal.incorrectAnswers = ["Human", "Plant", "Bioshere"]
        
        let highSchoolBiologyKit = Kit(context: coreDataManager.context)
        highSchoolBiologyKit.studyStage = StudyStage.highSchool.rawValue
        highSchoolBiologyKit.questions = [cell, photosynthesis, metabolism, genetics, molecule, evolution, naturalSelection, humanBrain, population, animal]
        highSchoolBiologyKit.name = "Biology"
        highSchoolBiologyKit.isBasicKit = true
        
        let broken = Question(context: coreDataManager.context)
        broken.question = "Break, broke, ___"
        broken.correctAnswer = "Broken"
        broken.incorrectAnswers = ["Breaken", "Breaked", "Broked"]
        let chose = Question(context: coreDataManager.context)
        chose.question = "Choose, ___, chosen"
        chose.correctAnswer = "Chose"
        chose.incorrectAnswers = ["Choosed", "Chosed", "Choosen"]
        let cut = Question(context: coreDataManager.context)
        cut.question = "Cut, ___, cut"
        cut.correctAnswer = "Cut"
        cut.incorrectAnswers = ["Cuted", "Cutted", "Cutten"]
        let understood = Question(context: coreDataManager.context)
        understood.question = "Understand, understood, ___"
        understood.correctAnswer = "Understood"
        understood.incorrectAnswers = ["Understanden", "Understand", "Understanded"]
        let think = Question(context: coreDataManager.context)
        think.question = "Think, thought, ___"
        think.correctAnswer = "Thought"
        think.incorrectAnswers = ["Thinked", "Think", "Thoughted"]
        let written = Question(context: coreDataManager.context)
        written.question = "Write, wrote, ___"
        written.correctAnswer = "Written"
        written.incorrectAnswers = ["Wrote", "Wroted", "Writtened"]
        let drew = Question(context: coreDataManager.context)
        drew.question = "Draw, ___, drawn"
        drew.correctAnswer = "Drew"
        drew.incorrectAnswers = ["Drawn", "Drawed", "Drawned"]
        let found = Question(context: coreDataManager.context)
        found.question = "Find, ___, found"
        found.correctAnswer = "Found"
        found.incorrectAnswers = ["Find", "Finded", "Founded"]
        let cost = Question(context: coreDataManager.context)
        cost.question = "Cost, cost, ___"
        cost.correctAnswer = "Cost"
        cost.incorrectAnswers = ["Costed", "Costted", "Costen"]
        let driven = Question(context: coreDataManager.context)
        driven.question = "Drive, drove, ___"
        driven.correctAnswer = "Driven"
        driven.incorrectAnswers = ["Droven", "Drived", "Droved"]
        
        let highSchoolIrregularVerbsKit = Kit(context: coreDataManager.context)
        highSchoolIrregularVerbsKit.studyStage = StudyStage.highSchool.rawValue
        highSchoolIrregularVerbsKit.questions = [broken, chose, cut, understood, think, written, drew, found, cost, driven]
        highSchoolIrregularVerbsKit.name = "Irregular verbs"
        highSchoolIrregularVerbsKit.isBasicKit = true
        
        // MARK: Life Activities Kits
        let commercial = Question(context: coreDataManager.context)
        commercial.question = "A commercially sponsored ad on radio or television"
        commercial.correctAnswer = "Commerical"
        commercial.incorrectAnswers = ["Audience", "CD", "Movie"]
        let camera = Question(context: coreDataManager.context)
        camera.question = "Equipment for taking photos"
        camera.correctAnswer = "Camera"
        camera.incorrectAnswers = ["TV", "CD-Player", "Computer"]
        let screen = Question(context: coreDataManager.context)
        screen.question = "A white or silvered surface where pictures can be projected for viewing"
        screen.correctAnswer = "Screen"
        screen.incorrectAnswers = ["TV", "Camera", "Phone"]
        let theatre = Question(context: coreDataManager.context)
        theatre.question = "You go here to watch a play"
        theatre.correctAnswer = "Theatre"
        theatre.incorrectAnswers = ["Museum", "Cinema", "Festival"]
        let boardGame = Question(context: coreDataManager.context)
        boardGame.question = "You play this sitting at a table"
        boardGame.correctAnswer = "Board game"
        boardGame.incorrectAnswers = ["Festival", "Competition", "Exibition"]
        let cinema = Question(context: coreDataManager.context)
        cinema.question = "You go here to see a film"
        cinema.correctAnswer = "Cinema"
        cinema.incorrectAnswers = ["Kino", "Movie", "Theatre"]
        let newspaper = Question(context: coreDataManager.context)
        newspaper.question = "In the morning my grandad loves to read news in a ___"
        newspaper.correctAnswer = "Newspaper"
        newspaper.incorrectAnswers = ["Cinema", "TV", "News"]
        let competition = Question(context: coreDataManager.context)
        competition.question = "You enter one of these to win a prize"
        competition.correctAnswer = "Competition"
        competition.incorrectAnswers = ["Play", "Music band", "Role play"]
        let chess = Question(context: coreDataManager.context)
        chess.question = "A board game, where goal is to checkmate opponent's king"
        chess.correctAnswer = "Chess"
        chess.incorrectAnswers = ["Checkers", "Tennis", "Dominoes"]
        let magazine = Question(context: coreDataManager.context)
        magazine.question = "Журнал"
        magazine.correctAnswer = "Magazine"
        magazine.incorrectAnswers = ["Newspaper", "The Internet", "Press"]
        
        let entertainmentAndMediaKit = Kit(context: coreDataManager.context)
        entertainmentAndMediaKit.studyStage = StudyStage.lifeActivities.rawValue
        entertainmentAndMediaKit.questions = [commercial, camera, screen, theatre, boardGame, cinema, newspaper, competition, chess, magazine]
        entertainmentAndMediaKit.name = "Entertainment and media"
        entertainmentAndMediaKit.isBasicKit = true
        
        let basketball = Question(context: coreDataManager.context)
        basketball.question = "A team game, where goal is to shoot a ball through the hoop with hands"
        basketball.correctAnswer = "Basketball"
        basketball.incorrectAnswers = ["Football", "Chess", "Tennis"]
        let volleyball = Question(context: coreDataManager.context)
        volleyball.question = "A game in which two teams hit an inflated ball over a high net using their hands"
        volleyball.correctAnswer = "Volleyball"
        volleyball.incorrectAnswers = ["Valleyball", "Tennis", "Football"]
        let course = Question(context: coreDataManager.context)
        course.question = "Golf is played on a golf ___"
        course.correctAnswer = "Course"
        course.incorrectAnswers = ["Field", "Court", "Table"]
        let draw = Question(context: coreDataManager.context)
        draw.question = "The scores were tied at the end, so the game was a ___"
        draw.correctAnswer = "Draw"
        draw.incorrectAnswers = ["Victory", "Defeat", "Lose"]
        let trophy = Question(context: coreDataManager.context)
        trophy.question = "After winning the tournament, Anna held up her ___"
        trophy.correctAnswer = "Trophy"
        trophy.incorrectAnswers = ["Pride", "Victory", "Draw"]
        let amateur = Question(context: coreDataManager.context)
        amateur.question = "What is the opposite of 'professional'?"
        amateur.correctAnswer = "Amateur"
        amateur.incorrectAnswers = ["Terrible", "Loser", "Opponent"]
        let rules = Question(context: coreDataManager.context)
        rules.question = "The referee should award a penalty if a player breaks one of the ___"
        rules.correctAnswer = "Rules"
        rules.incorrectAnswers = ["Records", "Opponents", "Rule"]
        let score = Question(context: coreDataManager.context)
        score.question = "What are the number of points won by each team or player in a sports event?"
        score.correctAnswer = "Score"
        score.incorrectAnswers = ["Record", "Referee", "Defeat"]
        let jockey = Question(context: coreDataManager.context)
        jockey.question = "In horse-racing the man who rides the horse is the ___"
        jockey.correctAnswer = "Jockey"
        jockey.incorrectAnswers = ["Racehorse", "Race driver", "Race course"]
        
        let sportsKit = Kit(context: coreDataManager.context)
        sportsKit.studyStage = StudyStage.lifeActivities.rawValue
        sportsKit.questions = [basketball, volleyball, course, draw, trophy, amateur, rules, score, jockey]
        sportsKit.name = "Sports"
        sportsKit.isBasicKit = true
        
        let change = Question(context: coreDataManager.context)
        change.question = "The balance of money received when the amount you tender is greater than the amount due"
        change.correctAnswer = "Change"
        change.incorrectAnswers = ["Pay", "Sell", "Resell"]
        let cheque = Question(context: coreDataManager.context)
        cheque.question = "A written order directing a bank to pay money"
        cheque.correctAnswer = "Cheque"
        cheque.incorrectAnswers = ["Cheap", "Check", "Note"]
        let credit = Question(context: coreDataManager.context)
        credit.question = "The amount of money loaned by a person"
        credit.correctAnswer = "Credit"
        credit.incorrectAnswers = ["Debit", "Payment", "Cheque"]
        let bill = Question(context: coreDataManager.context)
        bill.question = "An itemized statement of money owed for goods shipped or services rendered"
        bill.correctAnswer = "Bill"
        bill.incorrectAnswers = ["Rent", "Order", "Credit"]
        let cash = Question(context: coreDataManager.context)
        cash.question = "Money in the form of bills or coins"
        cash.correctAnswer = "Cash"
        cash.incorrectAnswers = ["Cheque", "Balance", "Payment"]
        let inexpensive = Question(context: coreDataManager.context)
        inexpensive.question = "Relatively low in price or charging low prices"
        inexpensive.correctAnswer = "Inexpensive"
        inexpensive.incorrectAnswers = ["Unexpensive", "Non-expensive", "Luxury"]
        let luxury = Question(context: coreDataManager.context)
        luxury.question = "Something thas is very expensive, rather for satisfaction than for needs"
        luxury.correctAnswer = "Luxury"
        luxury.incorrectAnswers = ["Lucksury", "Leisury", "Unique"]
        let mall = Question(context: coreDataManager.context)
        mall.question = "Торговый центр"
        mall.correctAnswer = "Shopping mall"
        mall.incorrectAnswers = ["Shipping mall", "Shopping center", "Shopping centre"]
        let payForPurchase = Question(context: coreDataManager.context)
        payForPurchase.question = "Переведите предложение: Заплатить за покупку"
        payForPurchase.correctAnswer = "To pay for a purchase"
        payForPurchase.incorrectAnswers = ["To pay for the purchase", "To pay for a buy", "To pay off a purchase"]
        let bargain = Question(context: coreDataManager.context)
        bargain.question = "Сделка"
        bargain.correctAnswer = "Bargain"
        bargain.incorrectAnswers = ["Agreement", "Shopping", "Luxury"]
        
        let shoppingKit = Kit(context: coreDataManager.context)
        shoppingKit.studyStage = StudyStage.lifeActivities.rawValue
        shoppingKit.questions = [change, cheque, credit, bill, cash, inexpensive, luxury, mall, payForPurchase, bargain]
        shoppingKit.name = "Shopping"
        shoppingKit.isBasicKit = true
        
        //MARK: Programming University Kits
        let varr = Question(context: coreDataManager.context)
        varr.question = "'var' stands for ___"
        varr.correctAnswer = "Variable"
        varr.incorrectAnswers = ["Constant", "String", "Array"]
        let arr = Question(context: coreDataManager.context)
        arr.question = "A collection that stores values of the same type in an ordered list"
        arr.correctAnswer = "Array"
        arr.incorrectAnswers = ["Set", "Dictionary", "Vocabulary"]
        let enums = Question(context: coreDataManager.context)
        enums.question = "Custom type that define a list of possible values"
        enums.correctAnswer = "Enumeration"
        enums.incorrectAnswers = ["Class", "Structure", "Variable"]
        let int = Question(context: coreDataManager.context)
        int.question = "'Int' stands for ___"
        int.correctAnswer = "Integer"
        int.incorrectAnswers = ["String", "Intermediate", "Nothing"]
        let extensions = Question(context: coreDataManager.context)
        extensions.question = "Adding of a functionality to an existing type is ___"
        extensions.correctAnswer = "Extension"
        extensions.incorrectAnswers = ["Subscript", "Variable", "Structure"]
        let classs = Question(context: coreDataManager.context)
        classs.question = "Custom reference type"
        classs.correctAnswer = "Class"
        classs.incorrectAnswers = ["Structure", "Enumeration", "Value"]
        let closure = Question(context: coreDataManager.context)
        closure.question = "Code that executes together, without creating a named function"
        closure.correctAnswer = "Closure"
        closure.incorrectAnswers = ["Func", "Array", "Method"]
        let viewDidLoad = Question(context: coreDataManager.context)
        viewDidLoad.question = "Method that is called after the controller's view is loaded into memory."
        viewDidLoad.correctAnswer = "viewDidLoad()"
        viewDidLoad.incorrectAnswers = ["viewWillAppear()", "viewDidAppear()", "viewWillDisappear()"]
        let singleton = Question(context: coreDataManager.context)
        singleton.question = "Software design pattern that restricts the initialization of a class to a singular instance"
        singleton.correctAnswer = "Singleton"
        singleton.incorrectAnswers = ["Builder", "Factory", "Structure"]
        
        let swiftKit = Kit(context: coreDataManager.context)
        swiftKit.studyStage = StudyStage.programmingUniversity.rawValue
        swiftKit.questions = [varr, arr, enums, int, extensions, classs, closure, viewDidLoad, singleton]
        swiftKit.name = "Swift"
        swiftKit.isBasicKit = true
        
        let software = Question(context: coreDataManager.context)
        software.question = "A computer program is a piece of ___"
        software.correctAnswer = "Software"
        software.incorrectAnswers = ["Hardware", "Undedwear", "Inware"]
        let hardDisk = Question(context: coreDataManager.context)
        hardDisk.question = "Part of a computer that stores programs and information"
        hardDisk.correctAnswer = "Hard disk"
        hardDisk.incorrectAnswers = ["Hotspot", "Notebook", "Soft disk"]
        let browser = Question(context: coreDataManager.context)
        browser.question = "Program for exploring the Web and viewing websites"
        browser.correctAnswer = "Browser"
        browser.incorrectAnswers = ["Scanner", "Driver", "Hardware"]
        let icon = Question(context: coreDataManager.context)
        icon.question = "To open a particular folder, file or app, you just have to click on its ___"
        icon.correctAnswer = "Icon"
        icon.incorrectAnswers = ["Pixel", "File", "Font"]
        let cpu = Question(context: coreDataManager.context)
        cpu.question = "A computer's ___ is called its heart because it's where data is processed."
        cpu.correctAnswer = "CPU"
        cpu.incorrectAnswers = ["RAM", "USB", "WAT"]
        let formatting = Question(context: coreDataManager.context)
        formatting.question = "___ is the process of dividing the disk into tracks and sectors"
        formatting.correctAnswer = "Formatting"
        formatting.incorrectAnswers = ["Tracking", "Crashing", "Alloitting"]
        let processing = Question(context: coreDataManager.context)
        processing.question = "Computers manipulate data in many ways, and this manipulation is called ___"
        processing.correctAnswer = "Processing"
        processing.incorrectAnswers = ["Batching", "Utilizing", "Upgrading"]
        let cookies = Question(context: coreDataManager.context)
        cookies.question = "___ are used to identify a user who returns to a website"
        cookies.correctAnswer = "Cookies"
        cookies.incorrectAnswers = ["Plug-ins", "Scripts", "ASPs"]
        let motherboard = Question(context: coreDataManager.context)
        motherboard.question = "The CPU and memory are located on the ___"
        motherboard.correctAnswer = "Motherboard"
        motherboard.incorrectAnswers = ["Storage device", "Output device", "Expansion board"]
        let mouseInput = Question(context: coreDataManager.context)
        mouseInput.question = "Mouse is an ___ device"
        mouseInput.correctAnswer = "Input"
        mouseInput.incorrectAnswers = ["Output", "Dispute", "Recording"]
        
        let computerKit = Kit(context: coreDataManager.context)
        computerKit.studyStage = StudyStage.programmingUniversity.rawValue
        computerKit.questions = [software, hardDisk, browser, icon, cpu, formatting, processing, cookies, motherboard, mouseInput]
        computerKit.name = "Computer"
        computerKit.isBasicKit = true
        
        // MARK: Construction University Kits
        let concrete = Question(context: coreDataManager.context)
        concrete.question = "Composite material that is created by mixing binding material along with the aggregate and water"
        concrete.correctAnswer = "Concrete"
        concrete.incorrectAnswers = ["Cement", "Wax", "Glass"]
        let cement = Question(context: coreDataManager.context)
        cement.question = "A chemical substance that sets, hardens, and adheres to other materials to bind them together"
        cement.correctAnswer = "Cement"
        cement.incorrectAnswers = ["Concrete", "Water", "Clay"]
        let steel = Question(context: coreDataManager.context)
        steel.question = "An alloy of iron and carbon with improved strength and fracture resistance compared to other forms of iron"
        steel.correctAnswer = "Steel"
        steel.incorrectAnswers = ["Cement", "Wood", "Wax"]
        let tile = Question(context: coreDataManager.context)
        tile.question = "Coverings from ceramics, stone, metal etc. usually of rectangular form"
        tile.correctAnswer = "Tile"
        tile.incorrectAnswers = ["Steel", "Clay", "Glass"]
        let brick = Question(context: coreDataManager.context)
        brick.question = "A rectangular block typically made of clay"
        brick.correctAnswer = "Brick"
        brick.incorrectAnswers = ["Tile", "Wood", "Steel"]
        let clay = Question(context: coreDataManager.context)
        clay.question = "Natural soil material used for making bricks"
        clay.correctAnswer = "Clay"
        clay.incorrectAnswers = ["Sand", "Water", "Gravel"]
        let gravel = Question(context: coreDataManager.context)
        gravel.question = "A loose aggregation of rock fragments"
        gravel.correctAnswer = "Gravel"
        gravel.incorrectAnswers = ["Sand", "Rocks", "Clay"]
        let asphalt = Question(context: coreDataManager.context)
        asphalt.question = "Material used as a road surface"
        asphalt.correctAnswer = "Asphalt"
        asphalt.incorrectAnswers = ["Clay", "Rock", "Sand"]
        
        let constructionMaterialsKit = Kit(context: coreDataManager.context)
        constructionMaterialsKit.studyStage = StudyStage.constructionUniversity.rawValue
        constructionMaterialsKit.questions = [concrete, cement, steel, tile, brick, clay, gravel, asphalt]
        constructionMaterialsKit.name = "Construction materials"
        constructionMaterialsKit.isBasicKit = true
        
        let foreman = Question(context: coreDataManager.context)
        foreman.question = "A person who exercises control over workers"
        foreman.correctAnswer = "Foreman"
        foreman.incorrectAnswers = ["Engineer", "Architect", "Contractor"]
        let contractor = Question(context: coreDataManager.context)
        contractor.question = "A person or organization hired to do the job"
        contractor.correctAnswer = "Contractor"
        contractor.incorrectAnswers = ["Builder", "Engineer", "Supervisor"]
        let subcontractor = Question(context: coreDataManager.context)
        subcontractor.question = "A person or organization hired from general contractor"
        subcontractor.correctAnswer = "Subcontractor"
        subcontractor.incorrectAnswers = ["Engineer", "Foreman", "Architect"]
        let architect = Question(context: coreDataManager.context)
        architect.question = "A person who plans, designs and oversees the construction of buildings"
        architect.correctAnswer = "Architect"
        architect.incorrectAnswers = ["Builder", "Contractor", "Foreman"]
        let designer = Question(context: coreDataManager.context)
        designer.question = "A person who develops design for the project"
        designer.correctAnswer = "Designer"
        designer.incorrectAnswers = ["Contractor", "Architect", "Engineer"]
        
        let constructionParticipantsKit = Kit(context: coreDataManager.context)
        constructionParticipantsKit.studyStage = StudyStage.constructionUniversity.rawValue
        constructionParticipantsKit.questions = [foreman, contractor, subcontractor, architect, designer]
        constructionParticipantsKit.name = "Construction participants"
        constructionParticipantsKit.isBasicKit = true
        
        // MARK: Side Job Kits
        let waiter = Question(context: coreDataManager.context)
        waiter.question = "A person who works in food-serving and drinking establishments"
        waiter.correctAnswer = "Waiter"
        waiter.incorrectAnswers = ["Builder", "Carpenter", "Singer"]
        let tip = Question(context: coreDataManager.context)
        tip.question = "A gift or a sum of money tendered for a service of a waiter"
        tip.correctAnswer = "Tip"
        tip.incorrectAnswers = ["Loan", "Cheque", "Tea"]
        let cocktail = Question(context: coreDataManager.context)
        cocktail.question = "Alcoholic mixed drink"
        cocktail.correctAnswer = "Cocktail"
        cocktail.incorrectAnswers = ["Juice", "Water", "Wine"]
        let wineglass = Question(context: coreDataManager.context)
        wineglass.question = "Бокал"
        wineglass.correctAnswer = "Wineglass"
        wineglass.incorrectAnswers = ["Bocal", "Glass", "Cup"]
        let etiquette = Question(context: coreDataManager.context)
        etiquette.question = "Этикет"
        etiquette.correctAnswer = "Etiquette"
        etiquette.incorrectAnswers = ["Ticket", "Eticket", "Table"]
        
        let waiterKit = Kit(context: coreDataManager.context)
        waiterKit.studyStage = StudyStage.sideJob.rawValue
        waiterKit.questions = [waiter, tip, cocktail, wineglass, etiquette]
        waiterKit.name = "Waiter"
        waiterKit.isBasicKit = true
        
        let driver = Question(context: coreDataManager.context)
        driver.question = "A person who drives a vehichle"
        driver.correctAnswer = "Driver"
        driver.incorrectAnswers = ["Driven", "Mover", "Engineer"]
        let vehicle = Question(context: coreDataManager.context)
        vehicle.question = "A technical device for transporting people and/or goods"
        vehicle.correctAnswer = "Vehicle"
        vehicle.incorrectAnswers = ["Veechle", "Thing", "Goose"]
        let route = Question(context: coreDataManager.context)
        route.question = "A way or course taken in getting from a starting point to a destination"
        route.correctAnswer = "Route"
        route.incorrectAnswers = ["Router", "Map", "App"]
        let seatBelt = Question(context: coreDataManager.context)
        seatBelt.question = "Always fasten your ___"
        seatBelt.correctAnswer = "Seat belt"
        seatBelt.incorrectAnswers = ["Seet belt", "Seatbelt", "Belt"]
        
        let taxiDriverKit = Kit(context: coreDataManager.context)
        taxiDriverKit.studyStage = StudyStage.sideJob.rawValue
        taxiDriverKit.questions = [driver, vehicle, route, seatBelt]
        taxiDriverKit.name = "Taxi driver"
        taxiDriverKit.isBasicKit = true
        
        let courier = Question(context: coreDataManager.context)
        courier.question = "A person who delivers a package"
        courier.correctAnswer = "Courier"
        courier.incorrectAnswers = ["Driver", "Waiter", "Cuorier"]
        let package = Question(context: coreDataManager.context)
        package.question = "An object or group of objects wrapped in paper or packed in a box"
        package.correctAnswer = "Package"
        package.incorrectAnswers = ["Letter", "Deliver", "Driver"]
        let late = Question(context: coreDataManager.context)
        late.question = "Arriving after necessary time"
        late.correctAnswer = "To be late"
        late.incorrectAnswers = ["To be plate", "To arrive", "To release"]
        let politeness = Question(context: coreDataManager.context)
        politeness.question = "Вежливость"
        politeness.correctAnswer = "Politeness"
        politeness.incorrectAnswers = ["Polite", "Plite", "Paliteness"]
        
        let courierKit = Kit(context: coreDataManager.context)
        courierKit.studyStage = StudyStage.sideJob.rawValue
        courierKit.questions = [courier, package, late, politeness]
        courierKit.name = "Courier"
        courierKit.isBasicKit = true
        
        save()
    }
}
