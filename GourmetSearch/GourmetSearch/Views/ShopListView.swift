//
//  ShopListView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import SwiftUI
import CoreLocation

/// 店舗検索結果を一覧表示する画面。
/// スクロールに応じて追加データを取得する。
struct ShopListView: View {

    /// 検索結果と読み込み状態を管理する ViewModel
    @ObservedObject var viewModel: ShopSearchViewModel

    /// 検索に使用する現在地
    let location: CLLocation?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {

                ForEach(viewModel.shops, id: \.id) { shop in
                    NavigationLink {
                        ShopDetailView(shop: shop)
                    } label: {
                        ShopRowView(shop: shop)
                            .onAppear {
                                guard let location else { return }

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

                // データ読み込み中のインジケーター
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }

                // 検索結果が空の場合
                if !viewModel.isLoading && viewModel.shops.isEmpty {
                    Text("検索結果がありません")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("検索結果")
        .navigationBarTitleDisplayMode(.inline)
    }
}
