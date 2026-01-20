//
//  ShopRowView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import SwiftUI

/// 店舗一覧で1行分の店舗情報を表示するビュー。
/// サムネイル画像・店舗名・アクセス情報を表示する。
struct ShopRowView: View {

    /// 表示対象の店舗データ
    let shop: Shop

    var body: some View {
        HStack(spacing: 12) {

            // 店舗のサムネイル画像を非同期で表示する
            AsyncImage(url: URL(string: shop.photo.mobile.s)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {

                // 店舗名
                Text(shop.name)
                    .font(.headline)
                    .lineLimit(2)

                // ジャンル
                Text(shop.genre.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // アクセス情報
                Text(shop.access)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
