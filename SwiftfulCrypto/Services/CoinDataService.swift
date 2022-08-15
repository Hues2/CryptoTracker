//
//  CoinDataService.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 12/08/2022.
//

import Foundation
import Combine

class CoinDataService : ObservableObject{
    @Published var allCoins = [CoinModel]()
    @Published var portfolioCoins = [CoinModel]()
    
    private var coinSubscription: AnyCancellable?
    
    init(){
        getCoins()
    }
    
    
    func getCoins(){
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h") else {return}
        
        coinSubscription = NetworkingManager.download(url: url)
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .sink { completion in
                NetworkingManager.handleCompletion(completion: completion)
            } receiveValue: { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
                self?.coinSubscription?.cancel()
            }

    }
}
