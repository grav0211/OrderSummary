//
//  CustomCell.swift
//  OrderSummary
//
//  Created by Alexandre Gravelle on 2018-07-12.
//  Copyright © 2018 Alexandre Gravelle. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func customInit(order: Order){
        self.titleLabel.text = "Order ID: \(order.orderNumber)"
        self.nameLabel.text = "Name: \(order.firstName) \(order.lastName)"
        self.totalPriceLabel.text = "Price: \(order.totalPrice) \(order.currency)"
        self.dateLabel.text = "Date: \(order.processed_date.prefix(10))"
        
        self.titleLabel.font = self.titleLabel.font.withSize(25)
        self.titleLabel.textColor = UIColor.colorWithHexString(hexStr: "#393E46")
        self.nameLabel.textColor = UIColor.colorWithHexString(hexStr: "#393E46")
        self.totalPriceLabel.textColor = UIColor.colorWithHexString(hexStr: "#393E46")
        self.dateLabel.textColor = UIColor.colorWithHexString(hexStr: "#393E46")
    }
    
}
