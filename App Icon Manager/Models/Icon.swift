//
//  Icon.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 14.12.20.
//

import Foundation

struct Icon: Identifiable {
    let id: UUID = UUID()
    let name: String
    let path: String
}
