//
//  MedicationController.swift
//  MedicatioManager
//
//  Created by Tanner Perry on 11/29/21.
//

import CoreData

class MedicationController {
    static let shared = MedicationController()
    let notificaitonScheduler = NotificationScheduler()
    
    private init() {}
    
    private lazy var fetchRequest: NSFetchRequest<Medication> = {
        let request = NSFetchRequest<Medication>(entityName: Strings.medicationEntitytype)
        request.predicate = NSPredicate(value: true)
        return request
    }()
    var sections: [[Medication]] { [notTakenMeds,takenMeds] }
    private var notTakenMeds: [Medication] = []
    private var takenMeds: [Medication] = []

    
    func create(name: String, timeOfDay: Date) {
        let medicaton = Medication(name: name, timeOfDay: timeOfDay)
        notTakenMeds.append(medicaton)
        CoreDataStack.saveContext()
        
        notificaitonScheduler.scheduleNotifications(for: medicaton)
    }
    
    func fetchMedication() {
        let medications = (try? CoreDataStack.context.fetch(self.fetchRequest)) ?? []
        takenMeds = medications.filter { $0.wasTakenToday() }
        notTakenMeds = medications.filter { !$0.wasTakenToday() }
//        self.medications = medications
    }

    func updateMedication(medication: Medication, name: String, timeOfDay: Date) {
        medication.name = name
        medication.timeOfDay = timeOfDay
        CoreDataStack.saveContext()
        
        notificaitonScheduler.cancelNotifications(for: medication)
        notificaitonScheduler.scheduleNotifications(for: medication)
    }
    
    func markMedicationasTaken(medication: Medication, wasTaken: Bool) {
        if wasTaken {
            TakenDate(date: Date(), medication: medication)
            if let index = notTakenMeds.firstIndex(of: medication)  {
                notTakenMeds.remove(at: index)
                takenMeds.append(medication)
            }
        } else {
            let mutabletakenDates = medication.mutableSetValue(forKey: Strings.takenDatesKey)
            if let takenDate = (mutabletakenDates as? Set<TakenDate>)?.first(where: { takenDate in
                guard let date = takenDate.date
                else { return false }
                
                return Calendar.current.isDate(date, inSameDayAs: Date())
            }) {
                mutabletakenDates.remove(takenDate)
                if let index = takenMeds.firstIndex(of: medication)  {
                    takenMeds.remove(at: index)
                    notTakenMeds.append(medication)
                }

                
            }
        }
        CoreDataStack.saveContext()
    }
    func markMedicationTaken(withID id: String) {
        guard let medication = notTakenMeds.first(where: { $0.id == id })
        else { return }
        
        markMedicationasTaken(medication: medication, wasTaken: true)
    }
    
    func deleteMedication(_ medication: Medication) {
        if let index = notTakenMeds.firstIndex(of: medication) {
            notTakenMeds.remove(at: index)
        } else if let index = takenMeds.firstIndex(of: medication) {
            takenMeds.remove(at: index)
        }
        
        CoreDataStack.context.delete(medication)
        CoreDataStack.saveContext()
        notificaitonScheduler.cancelNotifications(for: medication)
    }
}
//
//struct med {
//    let name: String
//    var takenDate: [Date]
//}
