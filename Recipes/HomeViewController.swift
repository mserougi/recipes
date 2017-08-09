//
//  HomeViewController.swift
//  Recipes
//
//  Created by Mohammed on 8/9/17.
//  Copyright © 2017 Purepoint. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var recipesTableView: UITableView!
    
    var recipes = [Recipe]()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        PuppyService().getRecipes(query: searchText, pageCount: 2) { (recipes: [Recipe]) in
            
            self.recipes = recipes
            
            self.recipesTableView.reloadData()
    
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        
        //print (recipes[indexPath.row].title)
        cell.textLabel?.text = recipes[indexPath.row].title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        return cell
    }
}

