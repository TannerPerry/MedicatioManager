//
//  MedicationTableViewCell.swift
//  MedicatioManager
//
//  Created by Tanner Perry on 11/29/21.
//

import UIKit

protocol medicationTableViewCellDelegate: AnyObject {
    func medicationWasTakenButtonTapped(medication: Medication, wasTaken: Bool)
}

class MedicationTableViewCell: UITableViewCell {
    
    weak var delegate: medicationTableViewCellDelegate?
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var wasTakenButton: UIButton!
    
    private var medication: Medication?
    private var wasTakenToday: Bool = false

    
    @IBAction func wasTakenButtonTapped(_ sender: UIButton) {
        guard let medication = medication
        else { return }
        
        wasTakenToday.toggle()
        
        delegate?.medicationWasTakenButtonTapped(medication: medication, wasTaken: wasTakenToday)
        
    }
    
    func configure(with medication: Medication) {
        self.medication = medication
        wasTakenToday = medication.wasTakenToday()
        
        nameLabel.text = medication.name
        timeLabel.text = DateFormatter.medicationTime.string(from: medication.timeOfDay ?? Date())
        let image = wasTakenToday ?  UIImage(systemName: "checkmark.square") : UIImage(systemName: "square")
        wasTakenButton.setImage(image, for: .normal)
    }
    
}
