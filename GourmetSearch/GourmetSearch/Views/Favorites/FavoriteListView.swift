//
//  FavoriteListView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/22.
//

import CoreLocation
import SwiftUI

/// お気に入り店舗一覧画面。
struct FavoriteListView: View {
    
    @EnvironmentObject private var favoriteStore: FavoriteStore
    @EnvironmentObject private var locationService: LocationService
    @StateObject private var viewModel = FavoriteListViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - 固定ヘッダー
            
            favoriteHeader
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 6)
            
            // MARK: - お気に入りリスト
            
            List {
                if viewModel.isEmpty {
                    emptyState
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(viewModel.favorites, id: \.id) { shop in
                        NavigationLink {
                            ShopDetailView(shop: shop)
                        } label: {
                            ShopRowView(
                                shop: shop,
                                userLocation: locationService.currentLocation
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        viewModel.promptDelete(offsets: offsets)
                    }
                }
            }
            .listStyle(.plain)
            .environment(\.editMode, .init(
                get: { viewModel.editMode },
                set: { viewModel.editMode = $0 }
            ))
        }
        .background(Color(.systemGroupedBackground))
        .tint(.primary)
        
        .navigationTitle("お気に入り")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // FavoriteStore を ViewModel にバインド
            viewModel.bind(favoriteStore: favoriteStore)
        }
        
        // MARK: - 編集ボタン（iOS標準UIではなく独自ボタン）
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { viewModel.toggleEditMode() } label: {
                    Text(viewModel.editMode == .active ? "完了" : "編集")
                        .font(.headline)
                }
            }
        }
        
        // MARK: - 削除確認アラート
        
        .alert("お気に入りを削除しますか？", isPresented: $viewModel.showDeleteAlert) {
            Button("削除", role: .destructive) { viewModel.confirmDelete() }
            Button("キャンセル", role: .cancel) { viewModel.cancelDelete() }
        } message: { Text("この操作は取り消せません。") }
    }
    
    // MARK: - 固定ヘッダー
    
    private var favoriteHeader: some View {
        ZStack(alignment: .leading) {
            
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.70, green: 0.45, blue: 0.12), location: 0.00),
                    .init(color: Color(red: 0.88, green: 0.64, blue: 0.22), location: 0.30),
                    .init(color: Color(red: 0.96, green: 0.78, blue: 0.36), location: 0.62),
                    .init(color: Color(red: 0.98, green: 0.86, blue: 0.48), location: 1.00)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            
            HStack(spacing: 14) {
                Image(systemName: "star.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("お気に入り")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(viewModel.countText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 75)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - 空状態UI
    
    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "star")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text("お気に入りはまだありません")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("検索画面から気になるお店を追加してみましょう")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
