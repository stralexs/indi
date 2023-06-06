//
//  StatisticsViewController.swift
//  Indi
//
//  Created by Alexander Sivko on 21.05.23.
//

import UIKit

class StatisticsViewController: UIViewController {
    @IBOutlet var background: UIView!
    @IBOutlet var statiscticsBackground: UIView!
    
    @IBOutlet var tableViews: [UITableView]!
    
    @IBOutlet var examProgressBackground: [UIView]!
    @IBOutlet var examProgress: [UIView]!
    @IBOutlet var examProgressWidth: [NSLayoutConstraint]!
    
    @IBOutlet var examResultsLabel: [UILabel]!
    
    @IBOutlet var testsCountLabel: UILabel!
    @IBOutlet var examsCountLabel: UILabel!
    @IBOutlet var correctAnswersCountLabel: UILabel!
    @IBOutlet var correctAnswersPercentageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tuneUI()
    }
    
    private func tuneUI() {
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.backgroundColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        self.navigationController?.navigationBar.standardAppearance = standardAppearance

        background.backgroundColor = UIColor(red: 54 / 255, green: 63 / 255, blue: 242 / 255, alpha: 1)
        statiscticsBackground.backgroundColor = UIColor(red: 1, green: 102 / 255, blue: 102 / 255, alpha: 1)
        statiscticsBackground.layer.cornerRadius = 10
        
        tableViews.forEach { tableView in
            tableView.dataSource = self
            tableView.layer.cornerRadius = 10
        }
        
        examProgressBackground.forEach { progressBackground in
            progressBackground.backgroundColor = UIColor(red: 1, green: 200 / 255, blue: 199 / 255, alpha: 1)
            progressBackground.layer.cornerRadius = 5
            progressBackground.clipsToBounds = true
        }
        
        examProgress.forEach {examProgess in
            examProgess.backgroundColor = UIColor(red: 1, green: 102 / 255, blue: 102 / 255, alpha: 1)
        }
        
        examProgressWidth.forEach { width in
            var totalWidth: Double {
                Double(examProgressBackground.first!.frame.width)
            }
            
            var coefficient: Double {
                totalWidth / 100
            }
            
            switch width.identifier {
            case "Newborn":
                width.constant = CGFloat(Double(UserData.shared.getUserResult(for: "Newborn exam")) * coefficient + 1)
            case "Preschool":
                width.constant = CGFloat(Double(UserData.shared.getUserResult(for: "Preschool exam")) * coefficient + 1)
            case "Early school":
                width.constant = CGFloat(Double(UserData.shared.getUserResult(for: "Early school exam")) * coefficient + 1)
            case "High school":
                width.constant = CGFloat(Double(UserData.shared.getUserResult(for: "High school exam")) * coefficient + 1)
            default:
                width.constant = CGFloat(Double(UserData.shared.getUserResult(for: "Final exam")) * coefficient + 1)
            }
        }
        
        examResultsLabel.forEach { label in
            switch label.tag {
            case 0:
                label.text = "\(UserData.shared.getUserResult(for: "Newborn exam"))%"
            case 1:
                label.text = "\(UserData.shared.getUserResult(for: "Preschool exam"))%"
            case 2:
                label.text = "\(UserData.shared.getUserResult(for: "Early school exam"))%"
            case 3:
                label.text = "\(UserData.shared.getUserResult(for: "High school exam"))%"
            default:
                label.text = "\(UserData.shared.getUserResult(for: "Final exam"))%"
            }
        }
        
        testsCountLabel.text = "\(UserData.shared.getUserStatistics().tests)"
        examsCountLabel.text = "\(UserData.shared.getUserStatistics().exams)"
        correctAnswersCountLabel.text = "\(UserData.shared.getUserStatistics().correct)"
        correctAnswersPercentageLabel.text = "\(UserData.shared.getUserStatistics().percentage)%"
    }
}

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return KitsLibrary.shared.countOfKits(for: 0)
        case 1:
            return KitsLibrary.shared.countOfKits(for: 1)
        case 2:
            return KitsLibrary.shared.countOfKits(for: 2)
        case 3:
            return KitsLibrary.shared.countOfKits(for: 3)
        case 4:
            return KitsLibrary.shared.countOfKits(for: 4)
        case 5:
            return KitsLibrary.shared.countOfKits(for: 5)
        case 6:
            return KitsLibrary.shared.countOfKits(for: 6)
        default:
            return KitsLibrary.shared.countOfKits(for: 7)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StatisticsTableViewCell
        
        var totalWidth: Double {
            Double(cell.background.frame.width)
        }
        
        var coefficient: Double {
            totalWidth / 100
        }
        
        switch tableView.tag {
        case 0:
            let kitName = KitsLibrary.shared.getKitName(for: 0, with: indexPath)
            cell.label.text = kitName
            cell.kitProgressViewWidth.constant = CGFloat(Double(UserData.shared.getUserResult(for: kitName)) * coefficient)
            cell.progressNumber.text = "\(UserData.shared.getUserResult(for: kitName))%"
        case 1:
            let kitName = KitsLibrary.shared.getKitName(for: 1, with: indexPath)
            cell.label.text = kitName
            cell.kitProgressViewWidth.constant = CGFloat(Double(UserData.shared.getUserResult(for: kitName)) * coefficient)
            cell.progressNumber.text = "\(UserData.shared.getUserResult(for: kitName))%"
        case 2:
            let kitName = KitsLibrary.shared.getKitName(for: 2, with: indexPath)
            cell.label.text = kitName
            cell.kitProgressViewWidth.constant = CGFloat(Double(UserData.shared.getUserResult(for: kitName)) * coefficient)
            cell.progressNumber.text = "\(UserData.shared.getUserResult(for: kitName))%"
        case 3:
            let kitName = KitsLibrary.shared.getKitName(for: 3, with: indexPath)
            cell.label.text = kitName
            cell.kitProgressViewWidth.constant = CGFloat(Double(UserData.shared.getUserResult(for: kitName)) * coefficient)
            cell.progressNumber.text = "\(UserData.shared.getUserResult(for: kitName))%"
        case 4:
            let kitName = KitsLibrary.shared.getKitName(for: 4, with: indexPath)
            cell.label.text = kitName
            cell.kitProgressViewWidth.constant = CGFloat(Double(UserData.shared.getUserResult(for: kitName)) * coefficient)
            cell.progressNumber.text = "\(UserData.shared.getUserResult(for: kitName))%"
        case 5:
            let kitName = KitsLibrary.shared.getKitName(for: 5, with: indexPath)
            cell.label.text = kitName
            cell.kitProgressViewWidth.constant = CGFloat(Double(UserData.shared.getUserResult(for: kitName)) * coefficient)
            cell.progressNumber.text = "\(UserData.shared.getUserResult(for: kitName))%"
        case 6:
            let kitName = KitsLibrary.shared.getKitName(for: 6, with: indexPath)
            cell.label.text = kitName
            cell.kitProgressViewWidth.constant = CGFloat(Double(UserData.shared.getUserResult(for: kitName)) * coefficient)
            cell.progressNumber.text = "\(UserData.shared.getUserResult(for: kitName))%"
        default:
            let kitName = KitsLibrary.shared.getKitName(for: 7, with: indexPath)
            cell.label.text = kitName
            cell.kitProgressViewWidth.constant = CGFloat(Double(UserData.shared.getUserResult(for: kitName)) * coefficient)
            cell.progressNumber.text = "\(UserData.shared.getUserResult(for: kitName))%"
        }
        
        cell.isUserInteractionEnabled = false
        
        return cell
    }
}
