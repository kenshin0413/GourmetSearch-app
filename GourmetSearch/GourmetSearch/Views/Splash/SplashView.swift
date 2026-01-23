//
//  SplashView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/23.
//

import SwiftUI

/// アプリ起動直後にアイコン画像のみを表示するシンプルなスプラッシュ。
struct SplashView: View {
    
    var body: some View {
        ZStack {
            // アイコン画像（アセット名: GourmetImage）
            Image("GourmetImage")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
        }
    }
}
