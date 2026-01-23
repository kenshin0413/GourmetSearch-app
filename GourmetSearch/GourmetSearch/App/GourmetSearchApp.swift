//
//  GourmetSearchApp.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/18.
//

import SwiftUI
@main
struct GourmetSearchApp: App {
    
    /// 位置情報の取得・管理を行うサービス（アプリ全体で共有）
    @StateObject private var locationService = LocationService()
    
    /// CoreData の永続化管理（シングルトン）
    private let persistence = PersistenceController.shared
    
    
    var body: some Scene {
        WindowGroup {
            
            /// お気に入り管理ストア（CoreData Context を注入）
            let favoriteStore = FavoriteStore(
                context: persistence.container.viewContext
            )
            
            AppRootView()
                .environmentObject(locationService)
                .environmentObject(favoriteStore)
                .environment(
                    \.managedObjectContext,
                     persistence.container.viewContext
                )
        }
    }
}
