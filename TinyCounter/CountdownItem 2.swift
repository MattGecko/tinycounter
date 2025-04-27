//
//  CountdownItem 2.swift
//  TinyCounter
//
//  Created by Doug Stitcher on 4/25/25.
//
import SwiftUI

struct CountdownItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var targetDate: Date
    var imageData: Data?
}
