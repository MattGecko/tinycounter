//
//  Haptics.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/22/25.
//


// Haptics.swift
import UIKit

struct Haptics {
    static func tap() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
