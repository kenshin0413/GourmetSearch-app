//
//  InfoCard.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/21.
//

import SwiftUI

// MARK: - 情報カード

/// InfoRow を入れる枠組みカードの生成。
struct InfoCard<Content: View>: View {
    
    /// カード内に表示するコンテンツ
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: 12) {
            content()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        }
    }
}

// MARK: - 情報行

/// 店舗詳細のタイトル・値・アイコンの配置を決める共通UIコンポーネント。
/// 店舗情報（住所・アクセス・営業時間など）の表示に使用する。
struct InfoRow: View {
    
    /// 表示する項目名（例：住所、営業時間）
    let title: String
    
    /// 表示する値テキスト
    let value: String
    
    /// 表示するSF Symbolsアイコン名
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            // 左側アイコン
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 22)
            
            // タイトル・値
            VStack(alignment: .leading, spacing: 4) {
                
                // 項目タイトル
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                // 項目の値（空文字の場合はダッシュ表示）
                Text(value.isEmpty ? "—" : value)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}
