//
//  LargeHitAreaView.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 10.02.2025.
//

import UIKit

// Класс с расширенной областью нажатия.
// Он переопределяет метод point(inside:with:), расширяя область hit-test на 20 поинтов с каждой стороны.
class LargeHitAreaView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let margin: CGFloat = 20
        let extendedBounds = self.bounds.insetBy(dx: -margin, dy: -margin)
        return extendedBounds.contains(point)
    }
}
