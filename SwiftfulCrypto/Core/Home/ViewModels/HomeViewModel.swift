//
//  HomeViewModel.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 11/08/2022.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject{
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    
    @Published var searchText: String = ""
    
    private let dataService = CoinDataService()
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        addSubscribers()
    }
    
    
    private func addSubscribers(){
        dataService.$allCoins
            .sink { completion in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    print("\n \(error.localizedDescription) \n")
                }
            } receiveValue: { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)

    }
    
}
