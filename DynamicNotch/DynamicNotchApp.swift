//
//  DynamicNotchApp.swift
//  DynamicNotch
//
//  Created by Nuh Naci Kusculu on 31.07.2024.
//

import SwiftUI

@main
struct DynamicNotchApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // We don't need a standard SwiftUI window.
        }
    }
}
