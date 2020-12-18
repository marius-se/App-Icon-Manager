//
//  VersionControlTree.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 17.12.20.
//

import Foundation

struct VersionControlTree: Decodable {
    struct Node: Decodable {
        enum NodeType: String, RawRepresentable, Decodable {
            case tree, blob, commit
        }
        
        let path: String
        let mode: String
        let type: NodeType
        let sha: String
        let url: URL
    }
    
    let sha: String
    let url: String
    let tree: [Node]
}
