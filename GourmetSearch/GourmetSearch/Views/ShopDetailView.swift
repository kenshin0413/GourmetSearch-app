//
//  ShopDetailView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import SwiftUI

/// 店舗の詳細情報を表示する画面
struct ShopDetailView: View {
    
    // MARK: - 入力データ
    
    /// 表示対象の店舗データ
    let shop: Shop
    
    /// 現在地サービス（距離計算に使用）
    @EnvironmentObject private var locationService: LocationService
    
    // MARK: - URL関連
    
    /// Apple Maps で住所検索するURL
    private var mapsURL: URL? {
        let encodedAddress = shop.address
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://maps.apple.com/?q=\(encodedAddress)")
    }
    
    /// 店舗の公式サイトURL（HotPepper）
    private var websiteURL: URL? {
        guard !shop.urls.pc.isEmpty else { return nil }
        return URL(string: shop.urls.pc)
    }
    
    // MARK: - 距離表示
    
    /// 現在地から店舗までの距離テキスト
    private var distanceText: String? {
        DistanceFormatter.text(
            from: locationService.currentLocation,
            to: shop.lat,
            longitude: shop.lng
        )
    }
    
    // MARK: - 支払い・駐車場情報
    
    /// カード利用可否の表示テキスト
    private var cardText: String {
        shop.card.isEmpty ? "不明" : shop.card
    }
    
    /// 駐車場の有無の表示テキスト
    private var parkingText: String {
        shop.parking.isEmpty ? "不明" : shop.parking
    }
    
    // MARK: - テキスト整形
    
    /// アクセス情報を見やすく整形する
    /// "/" の直後で改行する
    private var formattedAccessText: String {
        shop.access
            .replacingOccurrences(of: "/", with: "/\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - 営業状態判定
    
    /// 営業状態の表示用データ
    private var openingStatus: (text: String, color: Color)? {
        guard let isOpen = BusinessHoursParser.isOpen(text: shop.shopOpen) else {
            return ("営業時間不明", .gray.opacity(0.6))
        }
        
        if isOpen {
            return ("営業中", .green.opacity(0.75))
        } else {
            return ("営業時間外", .red.opacity(0.75))
        }
    }
    
    // MARK: - 画面構成
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                
                // メイン画像
                heroImage
                
                // 店舗名・バッジ表示
                headerSection
                
                // 地図・公式サイトボタン
                actionSection
                
                // 詳細情報カード
                infoSection
                
                Spacer(minLength: 12)
            }
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("店舗詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - メイン画像
    
    /// 店舗のメイン画像を表示する
    private var heroImage: some View {
        /// 非同期で画像を表示
        AsyncImage(url: URL(string: shop.photo.pc.l)) { image in
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
        .frame(height: 260)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - ヘッダー表示
    
    /// 店舗名・キャッチコピー・バッジを表示するエリア
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // 店舗名
            Text(shop.name)
                .font(.title2.weight(.bold))
                .lineLimit(3)
            
            // キャッチコピー
            if !shop.shopCatch.isEmpty {
                Text(shop.shopCatch)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
            }
            
            // バッジ表示
            HStack(spacing: 8) {
                
                // 距離
                if let distanceText {
                    badge(
                        text: distanceText,
                        background: Color(uiColor: .systemBlue).opacity(0.75)
                    )
                }
                
                // 営業状態
                if let status = openingStatus {
                    badge(
                        text: status.text,
                        background: status.color
                    )
                }
                
                // 予算
                if !shop.budget.average.isEmpty {
                    badge(
                        text: "予算 \(shop.budget.average)",
                        background: Color.green.opacity(0.7)
                    )
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - アクションボタンエリア
    
    /// 地図・公式サイトボタンを表示するエリア
    private var actionSection: some View {
        HStack(spacing: 12) {
            
            // 地図で開く
            if let mapsURL {
                Link(destination: mapsURL) {
                    actionButton(
                        title: "地図で開く",
                        icon: "map"
                    )
                }
            }
            
            // 公式サイトを開く
            if let websiteURL {
                Link(destination: websiteURL) {
                    actionButton(
                        title: "公式サイト",
                        icon: "safari"
                    )
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - 詳細情報カード表示
    
    /// 住所・営業時間・支払い情報などをカード形式で表示する
    private var infoSection: some View {
        VStack(spacing: 12) {
            
            // 住所・アクセス
            InfoCard {
                InfoRow(
                    title: "住所",
                    value: shop.address,
                    icon: "mappin.and.ellipse"
                )
                
                Divider().opacity(0.5)
                
                InfoRow(
                    title: "アクセス",
                    value: formattedAccessText,
                    icon: "figure.walk"
                )
            }
            
            // 営業時間・予算
            InfoCard {
                InfoRow(
                    title: "営業時間",
                    value: shop.shopOpen,
                    icon: "clock"
                )
                
                Divider().opacity(0.5)
                
                InfoRow(
                    title: "予算",
                    value: shop.budget.average,
                    icon: "yensign.circle"
                )
            }
            
            // カード・駐車場
            InfoCard {
                InfoRow(
                    title: "カード",
                    value: cardText,
                    icon: "creditcard"
                )
                
                Divider().opacity(0.5)
                
                InfoRow(
                    title: "駐車場",
                    value: parkingText,
                    icon: "parkingsign.circle"
                )
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - バッジ表示UI
    
    /// 距離・営業状態・予算などを表示する共通バッジUI
    private func badge(
        text: String,
        background: Color
    ) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(background)
            .clipShape(Capsule())
    }
    
    // MARK: - アクションボタンUI
    
    /// 詳細画面で使用するアクションボタンUI（地図ボタンと公式サイトボタン）
    private func actionButton(
        title: String,
        icon: String
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
                .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        }
    }
}
