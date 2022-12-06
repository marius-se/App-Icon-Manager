//
//  App.swift
//  AppIconManager
//
//  Created by Marius Seufzer on 23.08.22.
//

import Foundation
import SDWebImage

struct App: Identifiable, Equatable {
    var id: String { path }
    var name: String
    var path: String
    var icon: NSImage
}
