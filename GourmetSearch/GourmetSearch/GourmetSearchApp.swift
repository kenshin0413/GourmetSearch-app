//
//  GourmetSearchApp.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/18.
//

import SwiftUI

@main
struct GourmetSearchApp: App {
    
    /// アプリ全体で共有する位置情報サービス
    @StateObject private var locationService = LocationService()
    
    /// お気に入り管理ストア
    @StateObject private var favoriteStore = FavoriteStore()
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(locationService)
                .environmentObject(favoriteStore)
        }
    }
}
