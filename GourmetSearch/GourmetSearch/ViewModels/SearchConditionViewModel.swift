//
//  SearchConditionViewModel.swift
//  GourmetSearch
//
//  Created by refactor on R 8/01/26.
//

import Foundation
import CoreLocation

/// 検索条件のみを管理する ViewModel。
@MainActor
final class SearchConditionViewModel: ObservableObject {
    /// 検索半径
    @Published var searchRange: Int = 3
    /// 検索キーワード
    @Published var searchKeyword: String = ""
    
    // 画面状態
    @Published var showResultScreen: Bool = false
    @Published var showLocationDeniedAlert: Bool = false
    @Published var listViewModel: ShopListViewModel?
    
    /// 条件を用いて一覧用ViewModelを生成し、初回検索まで行う
    func createListAndSearch(from location: CLLocation) async {
        let vm = ShopListViewModel(
            searchRange: searchRange,
            searchKeyword: searchKeyword
        )
        await vm.startSearch(from: location)
        self.listViewModel = vm
        self.showResultScreen = true
    }
}
