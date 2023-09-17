//
//  UserModel.swift
//  CombineTest
//
//  Created by Bokyung on 2023/09/17.
//

import Foundation

struct User: Codable {
    let id: Int
    let email: String
    let name: String
    let company: Company
}

struct Company: Codable {
    let name: String
}
