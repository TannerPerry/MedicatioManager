//
//  DateFormatter+Extras.swift
//  MedicationManager
//
//  Created by Tanner Perry on 11/30/21.
//

import Foundation

extension DateFormatter{
    static let medicationTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}
