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
    var sectionsRelay: PublishRelay<[SectionModel<String, String>]> { get }
}

protocol TrainingModeViewModelLogic {
    func fetchKitsNamesAndSections()
    func setSliderMaximumValue(for indexPaths: [IndexPath])
    func cellViewModel(with item: SectionModel<String, String>.Item) -> TrainingModeTableViewCellViewModelLogic
    func isBasicKitCheck(for indexPath: IndexPath, for indexPathSection: Int) -> Bool
    func deleteUserKit(for indexPath: IndexPath, for indexPathSection: Int)
    func viewModelForTrainingModeTesting(kits: [IndexPath], questions: Int) -> TrainingModeTestingViewModelData & TrainingModeTestingViewModelLogic
}

final class TrainingModeViewModel: TrainingModeViewModelData {
    private let disposeBag = DisposeBag()
    let sectionsRelay = PublishRelay<[SectionModel<String, String>]>()
    let sliderMaximumValue = PublishRelay<Float>()
}

extension TrainingModeViewModel: TrainingModeViewModelLogic {
    func fetchKitsNamesAndSections() {
        let countOfSections = StudyStage.countOfStudyStages
        
        let sectionModels = (0..<countOfSections).map {
            let sectionName = StudyStage[$0]
            let kitsNames = KitsManager.shared.getKitNamesForStudyStage(with: [$0])
            return SectionModel(model: sectionName, items: kitsNames)
        }
        
        sectionsRelay.accept(sectionModels)
    }
    
    func setSliderMaximumValue(for indexPaths: [IndexPath]) {
        let questionsCount = indexPaths.map { Float(KitsManager.shared.getKitForTesting(for: $0[0], and: $0[1]).count) }
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
