//
//  AppDelegate.swift
//  DynamicNotch
//
//  Created by Nuh Naci Kusculu on 31.07.2024.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var notchWindowController: NotchWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = NSHostingView(rootView: ContentView())
        notchWindowController = NotchWindowController(contentView: contentView)
    }
}
