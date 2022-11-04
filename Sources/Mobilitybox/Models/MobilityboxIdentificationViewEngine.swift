import Foundation
import SwiftUI

public class MobilityboxIdentificationViewEngine {
    public static let shared = MobilityboxIdentificationViewEngine()
    
    class IdentificationViewEngineDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
        unowned var engineCode: MobilityboxIdentificationViewEngine! = nil
        
        init(engineCode: MobilityboxIdentificationViewEngine) {
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
    var fetchedEngineCode: String! = nil
    var identificationViewEngineDelegate: IdentificationViewEngineDelegate! = nil
    
    public class func setup(){
        shared.loadEngine()
        shared.updateEngine()
    }
    
    public init() {
        self.identificationViewEngineDelegate = IdentificationViewEngineDelegate(engineCode: self)
    }
    
    public func updateEngine() {
        let config = URLSessionConfiguration.default
        let url = URL(string: "\(Mobilitybox.api.apiURL)/ticketing/identification_view/1?inline=inline")!
        
        let session = URLSession(configuration: config, delegate: self.identificationViewEngineDelegate, delegateQueue: nil)
        
        let dataTask = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if let error = error {
                print("Error fetching identification view engine: \(error)")
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
            UserDefaults.standard.set(encodedEngineData, forKey: "MobilityboxIdentificationViewEngine")
            print("stored identification view engine")
        }
    }
    
    func loadEngine() {
        print("start load identification view engine...")
        if let data = UserDefaults.standard.data(forKey: "MobilityboxIdentificationViewEngine") {
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
        
        let engineCodeComponents = self.engineCode.components(separatedBy: versionDelimiter)
        let fetchedEngineCodeComponents = fetchedEngineCode.components(separatedBy: versionDelimiter)
        
        print("current IdentificationView Engine Components: \(engineCodeComponents)")
        print("fetched IdentificationView Engine Components: \(fetchedEngineCodeComponents)")

        if (fetchedEngineCodeComponents.count > engineCodeComponents.count || fetchedEngineCodeComponents.count == 1 ) {
            return true
        }
        
        let currentMajorTag = Int(engineCodeComponents[0]) ?? 0
        let fetchedMajorTag = Int(fetchedEngineCodeComponents[0]) ?? 0
        let currentMinorTag = Int(engineCodeComponents[1]) ?? 0
        let fetchedMinorTag = Int(fetchedEngineCodeComponents[1]) ?? 0
        let currentPatchTag = engineCodeComponents[2]
        let fetchedPatchTag = fetchedEngineCodeComponents[2]
        
        if currentMajorTag < fetchedMajorTag {
            return true
        } else if currentMajorTag == fetchedMajorTag {
            if currentMinorTag < fetchedMinorTag {
                return true
            } else if currentMinorTag == fetchedMinorTag {
                return currentPatchTag != fetchedPatchTag
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
        let regex = try! NSRegularExpression(pattern: "(.*\\/identification_view\\/)|(\\?.*)")
        let range = NSMakeRange(0, requestUrl.count)
        let engineCodeParam = regex.stringByReplacingMatches(in: requestUrl, options: [], range: range, withTemplate: "")
        
        return engineCodeParam.replacingOccurrences(of: "/", with: ".")
    }
    
}
