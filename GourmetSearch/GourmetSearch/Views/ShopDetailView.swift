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
            VStack(spacing: 24) {

                // 店舗のメイン画像を表示する
                AsyncImage(url: URL(string: shop.photo.pc.l)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 240)
                .clipped()

                VStack(alignment: .leading, spacing: 16) {

                    // 店舗名
                    Text(shop.name)
                        .font(.title.bold())

                    // キャッチコピー
                    if !shop.shopCatch.isEmpty {
                        Text(shop.shopCatch)
                            .foregroundStyle(.secondary)
                    }

                    infoRow(title: "住所", value: shop.address)
                    infoRow(title: "アクセス", value: shop.access)
                    infoRow(title: "営業時間", value: shop.shopOpen)
                    infoRow(title: "予算", value: shop.budget.average)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("店舗詳細")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 共通表示

    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
        }
    }
}
