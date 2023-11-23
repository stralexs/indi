//
//  TrainingModeViewModel.swift
//  Indi
//
//  Created by Alexander Sivko on 7.07.23.
//

import RxSwift
import RxCocoa
import RxDataSources

protocol TrainingModeViewModelData {
    var sliderMaximumValue: PublishRelay<Float> { get }
    var sectionsRelay: BehaviorRelay<[SectionModel<String, String>]> { get }
}

protocol TrainingModeViewModelLogic {
    func setSliderMaximumValue(for indexPaths: [IndexPath])
    func cellViewModel(with item: SectionModel<String, String>.Item) -> TrainingModeTableViewCellViewModelLogic
    func isBasicKitCheck(for indexPath: IndexPath, for indexPathSection: Int) -> Bool
    func deleteUserKit(for indexPath: IndexPath, for indexPathSection: Int)
    func viewModelForTrainingModeTesting(kits: [IndexPath], questions: Int) -> TrainingModeTestingViewModelData & TrainingModeTestingViewModelLogic
}

final class TrainingModeViewModel: TrainingModeViewModelData {
    private let disposeBag = DisposeBag()
    let sectionsRelay = BehaviorRelay<[SectionModel<String, String>]>(value: [])
    let sliderMaximumValue = PublishRelay<Float>()
    
    init() {
        fetchKitsNamesAndSections()
    }
}

extension TrainingModeViewModel: TrainingModeViewModelLogic {
    private func fetchKitsNamesAndSections() {        
        KitsManager.shared.kits
            .bind { kits in
                let countOfSections = StudyStage.countOfStudyStages
                
                let sectionModels = (0..<countOfSections).map { stage in
                    let sectionName = StudyStage[stage]
                    let kitsNames = kits.filter { $0.studyStage == stage }
                        .sorted { $0.name ?? "" < $1.name ?? "" }
                        .map { $0.name ?? "" }
                    return SectionModel(model: sectionName, items: kitsNames)
                }
                
                self.sectionsRelay.accept(sectionModels)
            }
            .disposed(by: disposeBag)
    }
    
    func setSliderMaximumValue(for indexPaths: [IndexPath]) {
        let questionsCount = indexPaths.map { indexPath in
            let studyStageKits = KitsManager.shared.kits.value.filter { $0.studyStage == indexPath.section }
            let kit = studyStageKits[indexPath.row]
            let questionsCount = kit.questions?.allObjects.count
            return Float(questionsCount ?? 0)
        }
        .reduce(0) { $0 + $1 }
        sliderMaximumValue.accept(questionsCount)
    }
    
    func cellViewModel(with item: SectionModel<String, String>.Item) -> TrainingModeTableViewCellViewModelLogic {
        return TrainingModeTableViewCellViewModel(kitName: Observable.just(item))
    }
    
    func isBasicKitCheck(for indexPath: IndexPath, for indexPathSection: Int) -> Bool {
        return KitsManager.shared.isBasicKitCheck(for: indexPath, for: indexPathSection)
    }
    
    func deleteUserKit(for indexPath: IndexPath, for indexPathSection: Int) {
        KitsManager.shared.deleteUserKit(for: indexPath, for: indexPathSection)
    }
    
    func viewModelForTrainingModeTesting(kits: [IndexPath], questions: Int) -> TrainingModeTestingViewModelData & TrainingModeTestingViewModelLogic {
        return TrainingModeTestingViewModel(soundManager: SoundManager(),
                                            selectedKits: kits,
                                            selectedQuestionsCount: questions)
    }
}
