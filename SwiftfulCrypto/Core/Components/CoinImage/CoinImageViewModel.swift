//
//  CoinImageViewModel.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 13/08/2022.
//

import Foundation
import SwiftUI
import Combine

class CoinImageViewModel: ObservableObject{
    @Published var image: UIImage? = nil
    @Published var isLoading: Bool = false
    
    private let coin: CoinModel
    private let dataService : CoinImageService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel){
        self.coin = coin
        self.dataService = CoinImageService(coin: coin)
        self.addSubscribers()
        self.isLoading = true
    }
    
    
    private func addSubscribers(){
        dataService.$image
            .sink(receiveCompletion: { [weak self] (_) in
                self?.isLoading = false
            }, receiveValue: { [weak self] (returnImage) in
                self?.image = returnImage
            })
            .store(in: &cancellables)
    }

}
