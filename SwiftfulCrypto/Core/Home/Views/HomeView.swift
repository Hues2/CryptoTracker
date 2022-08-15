//
//  HomeView.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 11/08/2022.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var vm: HomeViewModel
    @State private var showPortfolio: Bool = false // animate right
    @State private var showPortfolioView: Bool = false // new sheet
    
    

    var body: some View {
        ZStack{
            // Background Layer
            Color.theme.background
                .ignoresSafeArea()
                .sheet(isPresented: $showPortfolioView) {
                    PortfolioView()
                        .environmentObject(vm)
                }
            
            // Content Layer
            VStack{
                
                //MARK: - Home Header
                homeHeader
                
                
                //MARK: - Statistics
                HomeStatsView(showPortfolio: $showPortfolio)
                
                
                //MARK: - Search Bar
                SearchBarView(searchText: $vm.searchText)
                
                
                //MARK: - Column Titles
                columnTitles
                
                
                //MARK: - Lists
                if !showPortfolio{
                    allCoinsList
                        .transition(.move(edge: .leading))
                }
                if showPortfolio{
                    portfolioCoinsList
                        .transition(.move(edge: .trailing))
                }
                
                
                Spacer(minLength: 0)
            }//VStack
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            HomeView()
                .navigationBarHidden(true)
        }
        .environmentObject(dev.homeVM)
        
    }
}




extension HomeView{
    
    private var homeHeader: some View{
        HStack{
            CircleButtonView(iconName: showPortfolio ? "plus" : "info")
                .animation(.none, value: showPortfolio)
                .onTapGesture {
                    if showPortfolio{
                        showPortfolioView.toggle()
                    }
                }
                .background(
                    CircleButtonAnimationView(animate: $showPortfolio)
                )
            Spacer()
            
            Text(showPortfolio ? "Portflio" : "Live Prices")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundColor(.theme.accent)
                .animation(.none)
            
            Spacer()
            CircleButtonView(iconName: "chevron.right")
                .rotationEffect(Angle(degrees: showPortfolio ? 180 : 0))
                .onTapGesture {
                    withAnimation(.spring()){
                        showPortfolio.toggle()
                    }
                }
        }//HStack
        .padding(.horizontal)
    }
    
    

    private var allCoinsList: some View{
        List{
            ForEach(vm.allCoins){ coin in
                CoinRowView(coin: coin, showHoldingsColumn: false)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
            }
        }
        .listStyle(.plain)
        .refreshable {
            vm.reloadData()
        }
    }
    
    private var portfolioCoinsList: some View{
        List{
            ForEach(vm.portfolioCoins){ coin in
                CoinRowView(coin: coin, showHoldingsColumn: true)
                    .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 10))
            }
            
            
        }
        .listStyle(.plain)
        .refreshable {
            vm.reloadData()
        }
    }
    
    
    private var columnTitles: some View{
        HStack{
            Text("Coin")
            
            Spacer()
            
            if showPortfolio{
                Text("Holdings")
            }
            
            
            Text("Price")
                .frame(width: UIScreen.main.bounds.width / 3.5, alignment: .trailing)
            
            Button {
                withAnimation(.linear(duration: 2)){
                    vm.reloadData()
                }
            } label: {
                Image(systemName: "goforward")
                    .rotationEffect(Angle(degrees: vm.isLoading ? 360 : 0), anchor: .center)
            }

        }
        .font(.caption)
        .foregroundColor(.theme.secondaryText)
        .padding(.horizontal)
    }
    
}
