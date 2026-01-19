//
//  ShopDetailView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import SwiftUI

/// 店舗の詳細情報を表示する画面。
/// 画像・店舗名・住所・営業時間を表示する。
struct ShopDetailView: View {
    
    /// 表示対象の店舗データ
    let shop: Shop
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // 店舗のメイン画像を表示する
                AsyncImage(url: URL(string: shop.photo.mobile.s)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 240)
                .clipped()
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    // 店舗名
                    Text(shop.name)
                        .font(.title2)
                        .bold()
                    
                    // 住所
                    Text("住所")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(shop.address)
                    
                    // 営業時間
                    Text("営業時間")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(shop.shopOpen)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("店舗詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}
