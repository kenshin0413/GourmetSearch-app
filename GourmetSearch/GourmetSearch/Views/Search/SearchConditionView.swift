//
//  SearchConditionView.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/18.
//

import SwiftUI

/// 店舗検索の条件を入力する画面。
/// 現在地の表示・検索条件の入力・検索実行を担当するメイン画面。
struct SearchConditionView: View {
    
    // MARK: - 状態管理
    
    /// 位置情報の取得・住所変換を管理するサービス
    @EnvironmentObject var locationService: LocationService
    
    /// 検索結果画面への遷移制御フラグ
    @State private var showResultScreen = false

    /// 検索条件と検索処理を管理する（このViewでは）
    @StateObject private var resultViewModel = ShopSearchViewModel()

    /// 位置情報が拒否/制限されたときに表示するアラート制御
    @State private var showLocationDeniedAlert = false
    @Environment(\.openURL) private var openURL
    
    // MARK: - クイック検索キーワード
    
    /// ワンタップで検索キーワードを入力できるプリセット
    /// UI上では「人気の検索」として表示される
    private let quickKeywords: [String] = [
        "ラーメン", "焼肉", "寿司", "カフェ",
        "居酒屋", "定食", "イタリアン", "パン"
    ]
    
    // MARK: - 画面全体構成
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // MARK: - 固定ヘッダー
                
                header
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 6)
                
                // MARK: - スクロール領域
                
                ScrollView {
                    VStack(spacing: 18) {
                        
                        // 現在地を表示する
                        locationPill
                        
                        // キーワード入力欄
                        searchBar
                        
                        // 検索範囲（距離）選択チップ
                        rangeChips
                        
                        // 人気キーワードのクイック選択
                        quickTags
                        
                        // 検索実行ボタン
                        searchButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("グルメサーチ")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: locationService.authorizationStatus) { _, newValue in
                if newValue == .denied || newValue == .restricted {
                    showLocationDeniedAlert = true
                }
            }
            .onAppear {
                if locationService.authorizationStatus == .denied ||
                    locationService.authorizationStatus == .restricted {
                    showLocationDeniedAlert = true
                }
            }

            // 検索実行後に結果画面へ遷移
            .navigationDestination(isPresented: $showResultScreen) {
                ShopListView(
                    viewModel: resultViewModel
                )
            }
            .alert("位置情報がオフです", isPresented: $showLocationDeniedAlert) {
                Button("設定を開く") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("検索には「位置情報の許可（このAppの使用中）」が必要です。設定から位置情報をオンにしてください。")
            }
        }
    }
    
    // MARK: - ヘッダー
    
    /// 画面上部に表示されるグラデーションカード
    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.95),
                    Color.pink.opacity(0.85),
                    Color.red.opacity(0.75)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 75)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            HStack {
                
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text("近くの“おいしい”を探す")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("今いる場所の周辺店舗を検索")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - 現在地表示エリア
    
    /// 現在地の取得状態・住所・エラー状態を表示するピルUI
    private var locationPill: some View {
        HStack(spacing: 10) {
            Image(systemName: "location.fill")
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("現在地")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let address = locationService.addressText, !address.isEmpty {
                    // 住所が取得できた場合
                    Text(address)
                        .font(.body)
                        .lineLimit(1)
                    
                } else if locationService.authorizationStatus == .denied
                            || locationService.authorizationStatus == .restricted {
                    // 位置情報が拒否されている場合
                    Text("位置情報が許可されていません")
                        .font(.body)
                        .foregroundStyle(.red)
                        .lineLimit(1)
                    
                } else {
                    // 位置情報を取得中の場合
                    Text("取得中…")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 位置情報取得中のみローディング表示
            if locationService.addressText == nil &&
                !(locationService.authorizationStatus == .denied
                  || locationService.authorizationStatus == .restricted) {
                ProgressView()
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - キーワード入力欄
    
    /// 店舗検索キーワードを入力する検索バーUI
    private var searchBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("キーワード")
                .font(.headline)
            
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("例：カフェ / ラーメン / 居酒屋", text: $resultViewModel.searchKeyword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                
                // 入力中のみクリアボタンを表示
                if !resultViewModel.searchKeyword.isEmpty {
                    Button {
                        resultViewModel.searchKeyword = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    // MARK: - 検索範囲選択
    
    /// 検索半径をチップUIで選択するエリア
    private var rangeChips: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("検索範囲")
                .font(.headline)
            
            // API仕様に合わせた距離プリセット
            let items: [(Int, String)] = [
                (1, "300m"),
                (2, "500m"),
                (3, "1km"),
                (4, "2km"),
                (5, "3km")
            ]
            
            HStack(spacing: 10) {
                ForEach(items, id: \.0) { item in
                    rangeChip(value: item.0, title: item.1)
                }
            }
        }
    }
    
    /// 距離選択チップの単体UI
    private func rangeChip(value: Int, title: String) -> some View {
        let isSelected = (resultViewModel.searchRange == value)
        
        return Button {
            resultViewModel.searchRange = value
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .background(isSelected ? Color.blue : Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - クイックキーワード
    
    /// ワンタップで検索キーワードを入力できるプリセット一覧
    private var quickTags: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("人気の検索")
                .font(.headline)
            
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    ForEach(Array(quickKeywords.prefix(4)), id: \.self) { word in
                        keywordTag(word)
                    }
                }
                HStack(spacing: 10) {
                    ForEach(Array(quickKeywords.dropFirst(4).prefix(4)), id: \.self) { word in
                        keywordTag(word)
                    }
                }
            }
        }
    }
    
    /// クイックキーワード用のタグUI
    private func keywordTag(_ word: String) -> some View {
        Button {
            resultViewModel.searchKeyword = word
        } label: {
            Text(word)
                .font(.subheadline.weight(.semibold))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 検索実行ボタン
    
    /// 現在地が取得できた場合のみ有効になる検索実行ボタン
    private var searchButton: some View {
        Button {
            if let location = locationService.currentLocation {
                Task {
                    await resultViewModel.startSearch(from: location)
                }
                showResultScreen = true
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkle.magnifyingglass")
                Text("近くのお店を探す")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .foregroundStyle(.white)
        .background(canSearch ? Color.blue : Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
        .disabled(!canSearch)
        .padding(.top, 6)
    }
    
    /// 現在地が取得できているかどうか
    private var canSearch: Bool {
        locationService.currentLocation != nil
    }
}
