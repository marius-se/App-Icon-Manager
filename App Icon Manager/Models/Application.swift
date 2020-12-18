//
//  Application.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 14.12.20.
//

import Foundation

struct Application: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let path: String
}
