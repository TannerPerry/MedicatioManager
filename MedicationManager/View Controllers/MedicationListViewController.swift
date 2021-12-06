//
//  MedicationListViewController.swift
//  MedicatioManager
//
//  Created by Tanner Perry on 11/29/21.
//

import UIKit

class MedicationListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var moodSurveyButton: UIButton!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MedicationController.shared.fetchMedication()
        NotificationCenter.default.addObserver(self, selector: #selector(reminderFired), name: NSNotification.Name(Strings.medicationReminderReceived), object: nil)
        guard let survey = MoodSurveyController.shared.fetchTodaysSurvey()
        else { return }
        moodSurveyButton.setTitle(survey.mentalState, for: .normal)
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func surveyButtonTapped(_ sender: UIButton) {
        guard let MoodSurveyViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: Strings.moodSurveyController) as? MoodSurveyViewController else { return }
        MoodSurveyViewController.delegate = self
        navigationController?.present(MoodSurveyViewController, animated: true, completion: nil)
    }
    
    
        // MARK: - Navigation
    @objc private func reminderFired() {
        tableView.backgroundColor = .systemRed
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.tableView.backgroundColor = .systemBackground
        }

    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Strings.medicationDetailSegueidentifier,
           let indexPath = tableView.indexPathForSelectedRow,
           let destination = segue.destination as? MedicationDetailViewController {
            let medication = MedicationController.shared.sections[indexPath.section][indexPath.row]
            destination.medication = medication
        }
    }

}

extension MedicationListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return MedicationController.shared.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return MedicationController.shared.sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "medicationCell", for: indexPath) as? MedicationTableViewCell else { return UITableViewCell() }
        
        let medication = MedicationController.shared.sections[indexPath.section][indexPath.row]
        
        cell.configure(with: medication)
        cell.delegate = self
    
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Not Taken"
        } else if section == 1 {
            return "Taken"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let medication = MedicationController.shared.sections[indexPath.section][indexPath.row]
            MedicationController.shared.deleteMedication(medication)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
}

extension MedicationListViewController:UITableViewDelegate{
    
    
}

extension MedicationListViewController: medicationTableViewCellDelegate {
    
    func medicationWasTakenButtonTapped(medication: Medication, wasTaken: Bool) {
        MedicationController.shared.markMedicationasTaken(medication: medication, wasTaken: wasTaken)
        tableView.reloadData()
    }
    
    
}
extension MedicationListViewController: MoodSurveyViewControllerDelegate {
    func moodButtonTapped(with emoji: String) {
        MoodSurveyController.shared.didTapMoodEmoji(emoji)
        moodSurveyButton.setTitle(emoji, for: .normal)
    }
    
    
}
