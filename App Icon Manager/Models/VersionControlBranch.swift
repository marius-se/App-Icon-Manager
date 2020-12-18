//
//  VersionControlBranch.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 17.12.20.
//

import Foundation
import Combine

struct VersionControlBranch: Decodable {
    struct Commit: Decodable {
        let sha: String
    }
    let commit: Commit
}
