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
    
    /// 表示ロジック用の ViewModel
    @StateObject private var viewModel: ShopDetailViewModel
    
    // MARK: - 初期化
    
    init(shop: Shop) {
        self.shop = shop
        _viewModel = StateObject(wrappedValue: ShopDetailViewModel(shop: shop))
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
                        viewModel.favoriteTapped()
                    } label: {
                        Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                            .foregroundStyle(viewModel.isFavorite ? Color.yellow : Color.primary)
                    }
                }
            }
            .onAppear {
                // EnvironmentObject を ViewModel にバインド
                viewModel.bind(
                    favoriteStore: favoriteStore,
                    locationService: locationService
                )
            }
            
            // MARK: - トースト表示
            
            if viewModel.showToast {
                VStack {
                    Spacer()
                    
                    Text(viewModel.toastMessage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.black.opacity(0.8))
                        .clipShape(Capsule())
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut, value: viewModel.showToast)
            }
        }
    }
    
    // MARK: - メイン画像
    
    private var heroImage: some View {
        AsyncImage(url: URL(string: shop.photo.pc.l)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ZStack {
                Rectangle()
                    .fill(Color(.secondarySystemGroupedBackground))
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity)
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
                
                if let distanceText = viewModel.distanceText {
                    badge(
                        text: distanceText,
                        background: Color(uiColor: .systemBlue).opacity(0.75)
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
            
            if let mapsURL = viewModel.mapsURL {
                Link(destination: mapsURL) {
                    actionButton(
                        title: "地図で開く",
                        icon: "map"
                    )
                }
            }
            
            if let websiteURL = viewModel.websiteURL {
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
                    value: viewModel.formattedAccessText,
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
                    value: viewModel.cardText,
                    icon: "creditcard"
                )
                
                Divider().opacity(0.5)
                
                InfoRow(
                    title: "駐車場",
                    value: viewModel.parkingText,
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
