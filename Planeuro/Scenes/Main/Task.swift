//
//  Task.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import UIKit

struct Task {
    let title: String
    let categoryColor: UIColor
    let address: String
    let date: String
    var isActive: Bool

    init(title: String, categoryColor: UIColor, address: String, date: String, isActive: Bool) {
        self.title = title
        self.categoryColor = categoryColor
        self.address = address
        self.date = date
        self.isActive = isActive
    }
}
