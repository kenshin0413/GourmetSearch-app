//
//  RootTabView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/22.
//

import SwiftUI

/// アプリ全体のタブ構成を管理するルートビュー。
struct RootTabView: View {
    
    var body: some View {
        TabView {
            
            // MARK: - 検索タブ
            
            NavigationStack {
                SearchConditionView()
            }
            .tabItem {
                Label("検索", systemImage: "magnifyingglass")
            }
            
            // MARK: - お気に入りタブ
            
            NavigationStack {
                FavoriteListView()
            }
            .tabItem {
                Label("お気に入り", systemImage: "star.fill")
            }
        }
    }
}
