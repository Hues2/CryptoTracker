//
//  PortfolioView.swift
//  SwiftfulCrypto
//
//  Created by Greg Ross on 13/08/2022.
//

import SwiftUI

struct PortfolioView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject private var vm: HomeViewModel
    @State private var selectedCoin: CoinModel? = nil
    @State private var quantityText: String = ""
    @State private var showCheckMark: Bool = false
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(alignment: .leading, spacing: 0) {
                    
                    SearchBarView(searchText: $vm.searchText)
                    
                    
                    coinLogoList
                    
                    if selectedCoin != nil{
                        portfolioInputSection
                    }
                    
     
                }//VSTack
            }//ScrollView
            .navigationTitle("Edit Portfolio")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingNavBarButtons
                }
            }
        }
        
    }
}



struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
            .environmentObject(dev.homeVM)
    }
}

extension PortfolioView{
    private var coinLogoList: some View{
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10){
                ForEach(vm.allCoins) { coin in
                    CoinLogoView(coin: coin)
                        .frame(width: 75)
                        .padding(4)
                    
                        .onTapGesture {
                            withAnimation(.easeIn){
                                selectedCoin = coin
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.theme.green.opacity((coin.id == selectedCoin?.id) ? 1.0 : 0.0) , lineWidth: 1)
                        )

                }
            }
            .padding(.vertical, 4)
            .padding(.leading)
        }//Scrollview
    }
    
    
    
    private var portfolioInputSection: some View{
        VStack(spacing: 20){
            HStack{
                Text("Current price of: \(selectedCoin?.symbol.uppercased() ?? ""):")
                Spacer()
                Text(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")
            }
            
            Divider()
            
            HStack{
                Text("Amount holding:")
                Spacer()
                TextField("Ex: 1.4", text: $quantityText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
            }
            
            Divider()
            
            HStack{
                Text("Current value:")
                Spacer()
                Text(getCurrentValue().asCurrencyWith2Decimals())
            }
            
        }//VStack
        .animation(.none, value: selectedCoin?.id)
        .padding()
        .font(.headline)
    }
    
    
    
    
    private var trailingNavBarButtons: some View{
        HStack(spacing: 10){
            Image(systemName: "checkmark")
                .opacity(showCheckMark ? 1.0 : 0.0)
            
            Button {
                saveButtonPressed()
            } label: {
                Text("Save".uppercased())
            }
            .opacity(
                (selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText))
                ? 1.0 : 0.0
            )

        }
        .font(.headline)
    }
    
    
    
    private func getCurrentValue() -> Double{
        if let quantity = Double(quantityText){
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        return 0
    }
    
    
    private func saveButtonPressed(){
        guard let coin = selectedCoin else {return}
        
        // save to portfolio
        
        
        // show checkmark
        withAnimation(.easeIn){
            showCheckMark = true
            removeSelectedCoin()
        }
        
        // hide keyboard
        UIApplication.shared.endEditing()
        
        // hide checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
            withAnimation(.easeOut){
                showCheckMark = false
            }
        }
    }
    
    
    private func removeSelectedCoin(){
        selectedCoin = nil
        vm.searchText = ""
    }
    
}
