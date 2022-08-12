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
    
    private var cancellable: AnyCancellable?
    
    init(){
        getCoins()
    }
    
    
    private func getCoins(){
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1&sparkline=true&price_change_percentage=24h") else {return}
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (output) -> Data in
                guard let response = output.response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode < 300 else{
                    throw URLError(.badServerResponse)
                      }
                return output.data
            }
            .decode(type: [CoinModel].self, decoder: JSONDecoder())
            .sink { completion in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    print("\n \(error.localizedDescription) \n")
                }
            } receiveValue: { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
                self?.cancellable?.cancel()
            }

    }
    
    
    
}
