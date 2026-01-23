//
//  ShopDetailView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import SwiftUI

/// 店舗の詳細情報を表示する画面。
struct ShopDetailView: View {
    
    // MARK: - 入力データ
    
    /// 表示対象の店舗データ
    let shop: Shop
    
    /// 現在地サービス（距離計算に使用）
    @EnvironmentObject private var locationService: LocationService
    
    /// お気に入り管理ストア
    @EnvironmentObject private var favoriteStore: FavoriteStore
    
    // MARK: - トースト表示制御
    
    /// トースト表示フラグ
    @State private var showToast = false
    
    /// トーストに表示するメッセージ
    @State private var toastMessage = ""
    
    // MARK: - URL関連
    
    /// Apple Maps で住所検索する URL。
    private var mapsURL: URL? {
        let encodedAddress = shop.address
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://maps.apple.com/?q=\(encodedAddress)")
    }
    
    /// 店舗の公式サイト URL（HotPepper）。
    private var websiteURL: URL? {
        guard !shop.urls.pc.isEmpty else { return nil }
        return URL(string: shop.urls.pc)
    }
    
    // MARK: - 距離表示
    
    /// 現在地から店舗までの距離テキスト。
    private var distanceText: String? {
        DistanceFormatter.text(
            from: locationService.currentLocation,
            to: shop.lat,
            longitude: shop.lng
        )
    }
    
    // MARK: - 支払い・駐車場情報
    
    /// カード利用可否の表示テキスト。
    private var cardText: String {
        shop.card.isEmpty ? "不明" : shop.card
    }
    
    /// 駐車場の有無の表示テキスト。
    private var parkingText: String {
        shop.parking.isEmpty ? "不明" : shop.parking
    }
    
    // MARK: - テキスト整形
    
    /// アクセス情報を見やすく整形する。
    /// "/" の直後で改行する。
    private var formattedAccessText: String {
        shop.access
            .replacingOccurrences(of: "/", with: "/\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - 営業状態判定
    
    /// 営業状態の表示用データ。
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
    
    // MARK: - お気に入り状態
    
    /// お気に入り状態。
    private var isFavorite: Bool {
        favoriteStore.isFavorite(id: shop.id)
    }
    
    // MARK: - 画面構成
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 18) {
                    
                    heroImage
                    headerSection
                    actionSection
                    infoSection
                    
                    Spacer(minLength: 12)
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("店舗詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        handleFavoriteTapped()
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(isFavorite ? Color.yellow : Color.primary)
                    }
                }
            }
            
            // MARK: - トースト表示
            
            if showToast {
                VStack {
                    Spacer()
                    
                    Text(toastMessage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.black.opacity(0.8))
                        .clipShape(Capsule())
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut, value: showToast)
            }
        }
    }
    
    // MARK: - お気に入りボタン処理
    
    private func handleFavoriteTapped() {
        let wasFavorite = isFavorite
        favoriteStore.toggle(shop)
        
        // メッセージ切り替え
        toastMessage = wasFavorite
        ? "お気に入りから削除しました"
        : "お気に入りに追加しました"
        
        // トースト表示
        withAnimation {
            showToast = true
        }
        
        // 2秒後に自動で非表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
    
    // MARK: - メイン画像
    
    private var heroImage: some View {
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
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text(shop.name)
                .font(.title2.weight(.bold))
                .lineLimit(3)
            
            if !shop.shopCatch.isEmpty {
                Text(shop.shopCatch)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
            }
            
            HStack(spacing: 8) {
                
                if let distanceText {
                    badge(
                        text: distanceText,
                        background: Color(uiColor: .systemBlue).opacity(0.75)
                    )
                }
                
                if let status = openingStatus {
                    badge(
                        text: status.text,
                        background: status.color
                    )
                }
                
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
    
    private var actionSection: some View {
        HStack(spacing: 12) {
            
            if let mapsURL {
                Link(destination: mapsURL) {
                    actionButton(
                        title: "地図で開く",
                        icon: "map"
                    )
                }
            }
            
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
    
    private var infoSection: some View {
        VStack(spacing: 12) {
            
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
