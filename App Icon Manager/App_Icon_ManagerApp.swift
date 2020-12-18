//
//  App_Icon_ManagerApp.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 13.12.20.
//

import SwiftUI

@main
struct App_Icon_ManagerApp: App {
    var body: some Scene {
        WindowGroup {
            AppIconManagerView(viewModel: AppIconManagerViewModel())
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            SidebarCommands()
        }
    }
}
