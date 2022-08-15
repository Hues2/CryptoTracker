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
    
    @Published var isLoading: Bool = false
    
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
        
        
        
        // Updates portfolioCoins
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
//            .map({ (coinModels, portfolioEntities) -> [CoinModel] in
//                coinModels.compactMap { (coin) -> CoinModel? in
//                    guard let entity = portfolioEntities.first(where: {$0.coinId == coin.id}) else {return nil}
//
//                    return coin.updateHoldings(amount: entity.amount)
//
//                }
//            })
            .map(mapAllCoinsToPortfolioCoins)
            .sink { [weak self] returnedPortfolioCoins in
                self?.portfolioCoins = returnedPortfolioCoins
            }
            .store(in: &cancellables)
        
        
        
        // Updates marketData
        marketDataService.$marketData
            .combineLatest($portfolioCoins)
            // This publisher returns MarketDataModel, but we need to create a list of statistics
            // so the map function gets the needed data from the marketData and returns a list of statistics
            .map(mapGlobalMarketData)
        
            .sink { [weak self] returnedStats in
                self?.statistics = returnedStats
                self?.isLoading = false
            }
            .store(in: &cancellables)
        
        
        
    }
    
    
    func updatePortfolio(coin: CoinModel, amount: Double){
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    
    
    func reloadData(){
        isLoading = true
        coinDataService.getCoins()
        marketDataService.getData()
        HapticManager.notification(type: .success)
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
    
    
    private func mapAllCoinsToPortfolioCoins(allCoins: [CoinModel], portfolioEntities: [PortfolioEntity]) -> [CoinModel]{
        var portfolioCoins: [CoinModel] = []

        // Loop through allx the entities in the portfolio
        for portfolioEntity in portfolioEntities{
            // Get the coin from all coins that has the same id as the coinId in the entity and add it to the portfolioCoins
            if let coin = allCoins.first(where: {$0.id == portfolioEntity.coinId}){
                portfolioCoins.append(coin.updateHoldings(amount: portfolioEntity.amount))
            }
        }

        return portfolioCoins
    }
    
    
    
    
    
    private func mapGlobalMarketData(marketDataModel: MarketDataModel?, portfolioCoins: [CoinModel]) -> [StatisticModel]{
        var stats: [StatisticModel] = []
        
        guard let data = marketDataModel else {return stats}
        
        let marketCap = StatisticModel(title: "Market Cap", value: data.marketCap, percentageChange: data.marketCapChangePercentage24HUsd)
        
        let volume = StatisticModel(title: "24h Volume", value: data.volume)
        
        let btcDominance = StatisticModel(title: "BTC Dominance", value: data.btcDominance)
        
        
        let portfolioValue =
            portfolioCoins
                .map({$0.currentHoldingsValue})
                .reduce(0, +)
        
        
        let previousValue =
            portfolioCoins
            .map { (coin) -> Double in
                let currentValue = coin.currentHoldingsValue
                let percentChange = coin.priceChangePercentage24H ?? 0 / 100
                let previousValue = currentValue / (1 + percentChange)
                return previousValue
            }
            .reduce(0, +)
        
        let percentageChange = ((portfolioValue - previousValue) / previousValue) * 100
        

        let portfolio = StatisticModel(title: "Portfolio Value", value: portfolioValue.asCurrencyWith2Decimals(), percentageChange: percentageChange)
        
        stats.append(contentsOf: [
            marketCap,
            volume,
            btcDominance,
            portfolio
        ])
        
        return stats
    }
    
}
