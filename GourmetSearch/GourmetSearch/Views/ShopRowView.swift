//
//  ShopRowView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import SwiftUI
import CoreLocation

/// 店舗一覧で1店舗分の情報を「グルメアプリ風カードUI」で表示するビュー
struct ShopRowView: View {
    
    /// 表示対象の店舗データ
    let shop: Shop
    
    /// ユーザーの現在地（距離計算に使用）
    let userLocation: CLLocation?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - 店舗写真
            
            ZStack(alignment: .topTrailing) {
                
                AsyncImage(url: URL(string: shop.photo.mobile.l)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        Rectangle()
                            .fill(Color(.secondarySystemGroupedBackground))
                        
                        ProgressView()
                    }
                }
                .frame(height: 180)
                .clipped()
                
                // 右上に表示するバッジ（距離・営業状態）
                VStack(alignment: .trailing, spacing: 8) {
                    
                    // 現在地からの距離
                    if let distanceText {
                        badge(
                            text: distanceText,
                            icon: "location.fill",
                            background: Color(uiColor: .systemBlue).opacity(0.75)
                        )
                    }
                    
                    // 営業状態
                    if let status = openingStatus {
                        badge(
                            text: status.text,
                            icon: status.icon,
                            background: status.color
                        )
                    }
                }
                .padding(10)
            }
            
            // MARK: - 店舗情報エリア
            
            VStack(alignment: .leading, spacing: 10) {
                
                // 店舗名
                Text(shop.name)
                    .font(.headline)
                    .lineLimit(2)
                
                // ジャンル・予算
                HStack(spacing: 8) {
                    infoTag(text: shop.genre.name, icon: "fork.knife")
                    
                    if !shop.budget.average.isEmpty {
                        infoTag(text: shop.budget.average, icon: "yensign.circle")
                    }
                    
                    Spacer()
                }
                
                // キャッチコピー
                if !shop.shopCatch.isEmpty {
                    Text("“\(shop.shopCatch)”")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                Divider()
                    .opacity(0.7)
                
                // アクセス情報
                HStack(spacing: 8) {
                    Image(systemName: "train.side.front.car")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    
                    Text(shop.access)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
    }
    
    // MARK: - 距離表示
    
    /// 現在地から店舗までの距離テキスト
    private var distanceText: String? {
        DistanceFormatter.text(
            from: userLocation,
            to: shop.lat,
            longitude: shop.lng
        )
    }
    
    // MARK: - 営業状態判定
    
    /// 営業状態の表示用データ（テキスト・アイコン・色）
    private var openingStatus: (text: String, icon: String, color: Color)? {
        guard let isOpen = isCurrentlyOpen else {
            return ("営業時間不明", "questionmark.circle", .gray.opacity(0.6))
        }
        
        if isOpen {
            return ("営業中", "checkmark.circle.fill", .green.opacity(0.75))
        } else {
            return ("営業時間外", "moon.fill", .red.opacity(0.75))
        }
    }
    
    /// 現在時刻が営業時間内かどうか
    private var isCurrentlyOpen: Bool? {
        BusinessHoursParser.isOpen(text: shop.shopOpen)
    }
    
    // MARK: - 共通UI部品
    
    /// 検索結果画像の上に表示されてる距離と時間のパーツ
    private func badge(
        text: String,
        icon: String,
        background: Color = Color.black.opacity(0.35)
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 999))
    }
    
    /// ジャンル・予算表示用のタグUI
    private func infoTag(text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
            Text(text)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(.secondary)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 999))
    }
}
