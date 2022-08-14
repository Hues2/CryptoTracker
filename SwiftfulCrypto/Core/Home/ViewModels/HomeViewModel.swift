//
//  HomeViewModel.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 11/08/2022.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject{
    
    @Published var statistics: [StatisticModel] = [
        StatisticModel(title: "Title", value: "Value", percentageChange: 1),
        StatisticModel(title: "Title", value: "Value"),
        StatisticModel(title: "Title", value: "Value"),
        StatisticModel(title: "Title", value: "Value", percentageChange: -1)
    ]
    
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    
    @Published var searchText: String = ""
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortfolioDataService()
    
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        addSubscribers()
    }
    
    
    //MARK: - Add Subscribers
    private func addSubscribers(){
        
        // Updates allCoins
        $searchText
            .combineLatest(coinDataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
        
            // This map will use the text from the searchText and the allCoins from the dataService
            // it automatically places them into the filterCoins function parameters
            .map(filterCoins)
            .sink { [weak self] (returnedCoins) in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        
        // Updates marketData
        marketDataService.$marketData
            // This publisher returns MarketDataModel, but we need to create a list of statistics
            // so the map function gets the needed data from the marketData and returns a list of statistics
            .map(mapGlobalMarketData)
        
            .sink { [weak self] returnedStats in
                self?.statistics = returnedStats
            }
            .store(in: &cancellables)
        
        
        
        // Updates portfolioCoins
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map({ (coinModels, portfolioEntities) -> [CoinModel] in
                coinModels.compactMap { (coin) -> CoinModel? in
                    guard let entity = portfolioEntities.first(where: {$0.coinId == coin.id}) else {return nil}
                    
                    return coin.updateHoldings(amount: entity.amount)
                            
                }
            })
//            .map { [weak self] (coinModels, portfolioEntities) -> [CoinModel] in
//                var portfolioCoins: [CoinModel] = []
//
//                // Loop through all the entities in the portfolio
//                for portfolioEntity in portfolioEntities{
//                    // Get the coin from all coins that has the same id as the coinId in the entity and add it to the portfolioCoins
//                    if let coin = coinModels.first(where: {$0.id == portfolioEntity.coinId}){
//                        portfolioCoins.append(coin)
//                    }
//                }
//
//                return portfolioCoins
//            }
            .sink { [weak self] returnedPortfolioCoins in
                self?.portfolioCoins = returnedPortfolioCoins
            }
            .store(in: &cancellables)
            
    
    }
    
    
    func updatePortfolio(coin: CoinModel, amount: Double){
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    
    private func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel]{
        // No text in the searchbar
        guard !text.isEmpty else{
            return coins
        }
        
        // Search bar has text
        let lowercasedText = text.lowercased()
        
        return coins.filter { (coin) -> Bool in
            return coin.name.lowercased().contains(lowercasedText) || coin.symbol.lowercased().contains(lowercasedText)
            || coin.id.lowercased().contains(lowercasedText)
        }
    }
    
    
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?) -> [StatisticModel]{
        var stats: [StatisticModel] = []
        
        guard let data = marketDataModel else {return stats}
        
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        
        let volume = StatisticModel(title: "24h Volume", value: data.volume)
        
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
        
        let portfolio = StatisticModel(title: "Portfolio Value", value: "$0.00", percentageChange: 0)
        
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            portfolio
        ])
        
        return stats
    }
    
}
