//
//  APIManager.swift
//  LotteryScanner
//
//  Created by Enrique Barclay on 4/21/24.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    private let session = URLSession.shared
    
    func checkTicket(lotteryType: String, date: Date, numbers: [Int], megaNumber: Int, completion: @escaping (String, Error?) -> Void) {
        let formattedDate = formatDateForAPI(date: date)
        let numberStrings = numbers.map { String($0) }.joined(separator: "/")
        let formattedLotteryType = lotteryType.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: " ", with: "-")
        let urlString = "https://\(formattedLotteryType).p.rapidapi.com/CheckTicket/\(formattedDate)/\(numberStrings)/\(megaNumber)"
        
        guard let url = URL(string: urlString) else {
            completion("Invalid URL", NSError(domain: "", code: -1, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("95e36d8125msh739f557d193033ep1dbf10jsn7ee23ec2ae98", forHTTPHeaderField: "X-RapidAPI-Key")
        request.setValue("\(formattedLotteryType).p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion("", error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let data = data else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    completion("Failed to fetch data: HTTP Status \(statusCode)", NSError(domain: "", code: statusCode, userInfo: nil))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(result.data, nil)
                } catch {
                    completion("", error)
                }
            }
        }
        task.resume()
        
    }
    
    
    private func formatDateForAPI(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

struct APIResponse: Decodable {
    let status: String
    let data: String
}
