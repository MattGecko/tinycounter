// CounterModel.swift
import Foundation


struct CounterModel: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var count: Int
    var totalTaps: Int
    var createdDate: Date
    var religious: Bool
    var interval: Int

    // Custom init for creating manually
    init(id: UUID, title: String, count: Int, totalTaps: Int, createdDate: Date, religious: Bool, interval: Int) {
        self.id = id
        self.title = title
        self.count = count
        self.totalTaps = totalTaps
        self.createdDate = createdDate
        self.religious = religious
        self.interval = interval
    }

    // Custom decoding to support older saved data without interval
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        count = try container.decode(Int.self, forKey: .count)
        totalTaps = try container.decode(Int.self, forKey: .totalTaps)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        religious = try container.decode(Bool.self, forKey: .religious)
        interval = try container.decodeIfPresent(Int.self, forKey: .interval) ?? 1
    }
}

