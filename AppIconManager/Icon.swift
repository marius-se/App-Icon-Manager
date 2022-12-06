//
//  Icon.swift
//  AppIconManager
//
//  Created by Marius Seufzer on 22.08.22.
//

import Foundation

struct Icon: Identifiable, Equatable {
    let id: Int
    let fileURL: URL
    let name: String
    let author: String
    let lastModified: Date
}
