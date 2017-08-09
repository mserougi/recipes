//
//  PuppyService.swift
//  Recipes
//
//  Created by Mohammed on 8/9/17.
//  Copyright © 2017 Purepoint. All rights reserved.
//

import Foundation
import Alamofire

struct Endpoint {
    static let baseUrl = "http://www.recipepuppy.com/api/" // ?i=onions,garlic&q=omelet&p=3
}

class PuppyService: NSObject
{
    let operationQueue = OperationQueue()
    
    fileprivate func doGet(path: String, parameters: [String:Any], completion: @escaping (AnyObject?) -> Void)
    {
        Alamofire.request(path, method: .get, parameters: parameters).responseJSON { response in
            completion(response.result.value as AnyObject?)
        }
    }
    
    fileprivate func getPagedRecipes(query: String, page: Int, completion: @escaping ([Recipe]) -> Void) {
        
        var recipes = [Recipe]()
        
        let params: Parameters = ["q": query, "p": page]
        
        Alamofire.request(Endpoint.baseUrl, method: .get, parameters: params).responseJSON { response in
            
            if let result = response.result.value as? NSDictionary {
                
                if let objects = result["results"] as? NSArray {
                    
                    for i in 0 ..< objects.count {
                        
                        if let object = objects[i] as? NSDictionary {
                            
                            let recipe = Recipe()
                            
                            if let title = object["title"] as? String {
                                recipe.title = title
                            }
                            
                            recipes.append(recipe)
                        }
                    }
                }
            }
            
            completion(recipes)
        }
    }
    
    func getRecipes(query: String, pageCount: Int, completion: @escaping ([Recipe]) -> Void) {
        
        let pageLimit = 10
        var allRecipes = [Recipe]()
        
        self.getPagedRecipes(query: query, page: 1, completion: { (recipes: [Recipe]) in
            allRecipes.append(contentsOf: recipes)
            
            // There is no need to do the other operations if for a certain query
            // the total results are less than the page limit!
            if allRecipes.count == pageLimit {
                
                print ("Potential more than 10 - Operation queue will be used")
                
                self.operationQueue.cancelAllOperations()
                
                let completionOperation = BlockOperation {
                    completion(allRecipes)
                }
                
                for pageNumber in 1 ..< pageCount {
                    
                    let operation = BlockOperation {
                        
                        let s = DispatchSemaphore(value: 0)
                        
                        self.getPagedRecipes(query: query, page: pageNumber + 1, completion: { (recipes: [Recipe]) in
                            allRecipes.append(contentsOf: recipes)
                            
                            s.signal()
                        })
                        
                        s.wait()
                    }
                    
                    completionOperation.addDependency(operation)
                    self.operationQueue.addOperation(operation)
                }
                
                OperationQueue.main.addOperation(completionOperation)
            }
            else {
                // The number of results for this query was less than the page limit
                print ("Less than 10 - No operation queue needed ")
                
                completion(allRecipes)
            }
        })
    }
}
