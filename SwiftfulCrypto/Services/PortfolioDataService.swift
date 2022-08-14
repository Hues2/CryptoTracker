//
//  PortfolioDataService.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 14/08/2022.
//

import Foundation
import CoreData


class PortfolioDataService{
    
    @Published var savedEntities: [PortfolioEntity] = []
    
    private let container: NSPersistentContainer
    private let containerName: String = "PortfolioContainer"
    private let entityName: String = "PortfolioEntity"
    
    init(){
        container = NSPersistentContainer(name: containerName)
        
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("\n \("Error loading core data:") \(error) \n")
            }
            self.getPortfolio()
        }
    }
    
    
    //MARK: - Public Section
    
    func updatePortfolio(coin: CoinModel, amount: Double){
        // Check if coin is in portfolio
        if let entity = savedEntities.first(where: {$0.coinId == coin.id}){
            
            // If an amount has been passed in (greater than 0) then the user obviously wants to update it
            if amount > 0{
                update(entity: entity, amount: amount)
            } else{
                delete(entity: entity)
            }
            
        } else{
            // If the entity isn't in the portfolio container, then we need to add it
            add(coin: coin, amount: amount)
        }

    }
    
    
    //MARK: - Private Section
    
    private func getPortfolio(){
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
            
        do{
            savedEntities = try container.viewContext.fetch(request)
        } catch (let error){
            print("\n \("Error fetching portoflio entities:") \(error) \n")
        }
    }
    
    private func add(coin : CoinModel, amount: Double){
        let entity = PortfolioEntity(context: container.viewContext)
        
        entity.coinId = coin.id
        entity.amount = amount
        
        applyChanges()
    }
    
    private func update(entity: PortfolioEntity, amount: Double){
        entity.amount = amount
        applyChanges()
    }
    
    
    private func delete(entity: PortfolioEntity){
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    
    
    
    private func save(){
        do{
            try container.viewContext.save()
        } catch (let error){
            print("\n \("Error saving to core data:") \(error) \n")
        }
    }
    
    private func applyChanges(){
        save()
        getPortfolio()
    }
    
}
