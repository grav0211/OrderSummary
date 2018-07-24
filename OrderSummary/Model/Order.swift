//
//  Order.swift
//  OrderSummary
//
//  Created by Alexandre Gravelle on 2018-07-13.
//  Copyright © 2018 Alexandre Gravelle. All rights reserved.
//

import Foundation

class Order {
    let orderNumber: String,
    firstName: String,
    lastName: String,
    province: String,
    totalPrice: String,
    currency: String,
    processed_date: String
    
    init(orderNumber: String, firstName: String, lastName: String, province: String, totalPrice: String, currency: String, processed_date: String) {
        self.orderNumber = orderNumber
        self.firstName = firstName
        self.lastName = lastName
        self.province = province
        self.totalPrice = totalPrice
        self.currency = currency
        self.processed_date = processed_date
    }
}
