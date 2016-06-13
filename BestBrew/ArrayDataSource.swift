
import Foundation
import UIKit

typealias TableViewCellConfigureBlock = (cell:UITableViewCell, item:Tip?) -> ()

class ArrayDataSource: NSObject, UITableViewDataSource {
    
    var items:[Tip]
    let itemIdentifier:String
    let configureCellBlock:TableViewCellConfigureBlock
    
    init(items: [Tip], cellIdentifier: String, configureBlock: TableViewCellConfigureBlock) {
        
        self.items = items
        self.itemIdentifier = cellIdentifier
        self.configureCellBlock = configureBlock
        super.init()
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "TIPS"
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(itemIdentifier, forIndexPath: indexPath)
        let item: Tip = self.itemAtIndexPath(indexPath)
        
        configureCellBlock(cell: cell, item: item)
        
        return cell
    }
    
    private func itemAtIndexPath(indexPath: NSIndexPath) -> Tip {
        return self.items[indexPath.row]
    }
}