//
//  AppRootView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/23.
//

import SwiftUI

/// アプリ起動フロー（スプラッシュ表示→メイン画面）を管理するルートView。
struct AppRootView: View {
    // MARK: - 状態
    
    @State private var showSplash = true
    
    // MARK: - ビュー構成
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                RootTabView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // 起動後、約1.5秒でスプラッシュをフェードアウトする。
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showSplash = false
                }
            }
        }
    }
}
