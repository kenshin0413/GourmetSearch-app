//
//  GourmetSearchApp.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/18.
//

import SwiftUI

@main
struct GourmetSearchApp: App {
    
    @StateObject private var locationService = LocationService()
    
    var body: some Scene {
        WindowGroup {
            SearchConditionView()
                .environmentObject(locationService)
        }
    }
}
