//
//  Medication+convenience.swift
//  MedicatioManager
//
//  Created by Tanner Perry on 11/30/21.
//

import CoreData

extension Medication {
    @discardableResult convenience init(name: String, timeOfDay: Date, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.id = UUID().uuidString
        self.name = name
        self.timeOfDay = timeOfDay
    }
    
    func wasTakenToday() -> Bool {
        if (takenDates as? Set<TakenDate>)?.contains(where: { takenDates in
            guard let date = takenDates.date
            else { return false }
            
            return Calendar.current.isDate(date, inSameDayAs: Date())
        }) == true {
            return true
        } else {
            return false
        }
    }
}
