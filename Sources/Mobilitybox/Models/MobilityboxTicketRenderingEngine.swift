//
//  File.swift
//  
//
//  Created by René Meye on 11.06.22.
//

import Foundation
import SwiftUI


public struct MobilityboxEngineData: Codable {
    var engineCode: String
    var engineString: String
}

public class MobilityboxTicketRenderingEngine {
    class TicketRenderingEngineDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
        unowned var engineCode: MobilityboxTicketRenderingEngine! = nil
        
        init(engineCode: MobilityboxTicketRenderingEngine) {
            self.engineCode = engineCode
        }
        
        func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
            let fetchedEngineCode = self.engineCode.engineRequestUrlToEngineCode(requestUrl: request.url!.absoluteString)
            self.engineCode.fetchedEngineCode = fetchedEngineCode
            
            if (self.engineCode.isFetchedEngineCodeNewer(fetchedEngineCode: fetchedEngineCode)) {
                completionHandler(request)
            } else {
                completionHandler(nil)
            }
        }
        
    }
    
    public var engineCode: String! = nil
    public var engineString: String! = nil
    let mobilityboxAPI: MobilityboxAPI
    var fetchedEngineCode: String! = nil
    var ticketRenderingEngineDelegate: TicketRenderingEngineDelegate! = nil
    
    public init() {
        self.mobilityboxAPI = MobilityboxAPI()
        self.ticketRenderingEngineDelegate = TicketRenderingEngineDelegate(engineCode: self)
        self.loadEngine()
        self.updateEngine()
    }
    
    public init(mobilityboxAPI: MobilityboxAPI) {
        self.mobilityboxAPI = mobilityboxAPI
        self.ticketRenderingEngineDelegate = TicketRenderingEngineDelegate(engineCode: self)
        self.loadEngine()
        self.updateEngine()
    }
    
    public func updateEngine() {
        let config = URLSessionConfiguration.default
        let url = URL(string: "\(mobilityboxAPI.renderEngineURL)/engine/1?inline=inline")!

        let session = URLSession(configuration: config, delegate: self.ticketRenderingEngineDelegate, delegateQueue: nil)

        let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if let error = error {
                print("Error fetching render engine: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error with HTTP Connection: \(String(describing: response))")
                return
            }
            
            if httpResponse.statusCode == 302 {
                DispatchQueue.main.async {
                    self.loadEngine()
                }
                return
            } else {
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        if let engineStringResponse = String(data: data, encoding: String.Encoding.utf8) {
                            DispatchQueue.main.async {
                                self.saveEngine(engineString: engineStringResponse)
                            }
                        }
                    }
                } else {
                    print("Fetching render engine returend an unknown status code: \(String(describing: response))")
                    return
                }
            }
        })

        dataTask.resume()
    }
    
    func saveEngine(engineString: String) {
        self.engineCode = self.fetchedEngineCode
        self.engineString = engineString
        self.fetchedEngineCode = nil
        
        if let encodedEngineData = try? JSONEncoder().encode(MobilityboxEngineData(engineCode: self.engineCode, engineString: self.engineString)) {
            UserDefaults.standard.set(encodedEngineData, forKey: "MobilityboxTicketRenderingEngine")
            print("stored render engine")
        }
    }
    
    func loadEngine() {
        print("start load Engine...")
        if let data = UserDefaults.standard.data(forKey: "MobilityboxTicketRenderingEngine") {
            if let decodedEngineData = try? JSONDecoder().decode(MobilityboxEngineData.self, from: data) {
                self.engineCode = decodedEngineData.engineCode
                self.engineString = decodedEngineData.engineString
                self.fetchedEngineCode = nil
                
                print("done")
                return
            }
        }
    }
    
    func isFetchedEngineCodeNewer(fetchedEngineCode: String) -> Bool {
        let versionDelimiter = "."
        
        if self.engineCode == nil {
            return true
        }

        let engineCodeComponents = self.engineCode.components(separatedBy: versionDelimiter) // <1>
        let fetchedEngineCodeComponents = fetchedEngineCode.components(separatedBy: versionDelimiter)
        
        if engineCodeComponents[0] < fetchedEngineCodeComponents[0] {
            return true
        } else if engineCodeComponents[0] == fetchedEngineCodeComponents[0] {
            if engineCodeComponents[1] < fetchedEngineCodeComponents[1] {
                return true
            } else if engineCodeComponents[1] == fetchedEngineCodeComponents[1] {
                return engineCodeComponents[2] != fetchedEngineCodeComponents[2]
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func engineCodeToParamText() -> String {
        return self.engineCode.replacingOccurrences(of: ".", with: "/")
    }
    
    func engineRequestUrlToEngineCode(requestUrl: String) -> String {
        let regex = try! NSRegularExpression(pattern: "(.*\\/engine\\/)|(\\?.*)")
        let range = NSMakeRange(0, requestUrl.count)
        let engineCodeParam = regex.stringByReplacingMatches(in: requestUrl, options: [], range: range, withTemplate: "")
        
        return engineCodeParam.replacingOccurrences(of: "/", with: ".")
    }
    
}
