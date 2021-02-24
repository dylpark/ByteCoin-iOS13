//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Dylan Park on 24/02/2021.
//  Copyright © 2021 The App Brewery. All rights reserved.
//

import Foundation

//By convention, Swift protocols are usually written in the file that has the class/struct which will call the delegate methods, i.e. the CoinManager.
protocol CoinManagerDelegate {
    
    //Creating the method stubs wihtout implementation in the protocol.
    //It's usually a good idea to also pass along a reference to the current class.
    //e.g. func didUpdatePrice(_ coinManager: CoinManager, price: String, currency: String)
    //Check the Clima module for more info on this.
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
    
}

struct CoinManager {
    
    //An optional delegate that will have to implement the delegate methods, which we can notify when we have updated the price.
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = ""
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"

        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    
                    if let bitcoinPrice = self.parseJSON(safeData) {
                        
                        //Optional: round the price down to 2 decimal places.
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        
                        //Call the delegate method in the delegate (ViewController) and
                        //pass along the necessary data.
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
            
            //Creating a JSONDecoder
            let decoder = JSONDecoder()
            do {
                
                //Decode the data using the CoinData structure
                let decodedData = try decoder.decode(CoinData.self, from: data)
                
                //Get the last property from the decoded data
                let lastPrice = decodedData.rate
                print(lastPrice)
                return lastPrice
                
            } catch {
                
                //Catch and print any errors
                print(error)
                return nil
            }
        }
    

}
