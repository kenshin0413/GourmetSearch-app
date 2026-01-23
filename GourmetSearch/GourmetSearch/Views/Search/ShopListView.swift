//
//  ShopListView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import SwiftUI

/// 店舗検索結果を一覧表示する画面。
struct ShopListView: View {
    
    /// 検索結果と読み込み状態を管理する ViewModel
    @ObservedObject var viewModel: ShopSearchViewModel
    
    /// 現在地・住所情報を管理する LocationService
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14, pinnedViews: [.sectionHeaders]) {
                
                // 検索条件エリア（上部固定表示）
                Section(header: pinnedHeader) {
                    
                    // 検索結果が空の場合の表示
                    if !viewModel.isLoading && viewModel.shops.isEmpty {
                        emptyState
                            .padding(.top, 24)
                    } else {
                        
                        // 店舗カード一覧
                        ForEach(viewModel.shops, id: \.id) { shop in
                            NavigationLink {
                                // 店舗詳細画面へ遷移
                                ShopDetailView(shop: shop)
                            } label: {
                                ShopRowView(
                                    shop: shop,
                                    userLocation: locationService.currentLocation
                                )
                                // セルが表示されたタイミングで追加読み込みを判定
                                .onAppear {
                                    guard let location = locationService.currentLocation else { return }
                                    
                                    Task {
                                        await viewModel.loadMoreIfNeeded(
                                            currentShop: shop,
                                            location: location
                                        )
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // データ取得中のローディング表示
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding(.vertical, 18)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("検索結果")
        .navigationBarTitleDisplayMode(.inline)
        
        .refreshable {
            guard let location = locationService.currentLocation else { return }
            await viewModel.startSearch(from: location)
        }
    }
    
    // MARK: - 固定表示ヘッダー
    
    /// 検索条件と状態を表示する固定ヘッダー。
    private var pinnedHeader: some View {
        VStack(spacing: 10) {
            
            // API通信・データ取得に失敗した場合のエラー表示
            if let error = viewModel.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .lineLimit(2)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            // 検索結果件数と取得状態の表示
            HStack(spacing: 10) {
                Text("見つかったお店")
                    .font(.headline)
                
                Text("\(viewModel.shops.count)件")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // データ取得中のステータス表示
                if viewModel.isLoading && !viewModel.shops.isEmpty {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("読み込み中")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // 検索条件チップ（横スクロール）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    
                    // 検索キーワード（未入力の場合は「すべて」）
                    conditionChip(
                        icon: "magnifyingglass",
                        title: viewModel.searchKeyword.isEmpty ? "すべて" : viewModel.searchKeyword
                    )
                    
                    // 検索範囲
                    conditionChip(
                        icon: "location.circle.fill",
                        title: rangeText(viewModel.searchRange)
                    )
                    
                    // 現在地の住所表示
                    conditionChip(
                        icon: "mappin.and.ellipse",
                        title: locationService.addressText ?? "現在地"
                    )
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
        
        // 半透明背景で固定ヘッダー感を演出
        .background(.ultraThinMaterial)
        
        // 角丸と枠線でカード風の見た目にする
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        }
        .padding(.bottom, 4)
    }
    
    /// 検索条件チップの共通UI。
    private func conditionChip(icon: String, title: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 999))
    }
    
    /// 検索範囲の数値を表示用テキストに変換する。
    private func rangeText(_ range: Int) -> String {
        switch range {
        case 1: return "300m"
        case 2: return "500m"
        case 3: return "1km"
        case 4: return "2km"
        case 5: return "3km"
        default: return "\(range)"
        }
    }
    
    // MARK: - 検索結果が空のときの表示
    
    /// 検索結果が0件だった場合に表示するUI。
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text("検索結果がありません")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("キーワードや範囲を変えて再検索してみてください")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
