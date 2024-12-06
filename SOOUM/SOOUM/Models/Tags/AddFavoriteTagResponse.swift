//
//  AddFavoriteTagResponse.swift
//  SOOUM
//
//  Created by JDeoks on 12/6/24.
//

import Foundation

// MARK: - AddFavoriteTagResponse
struct AddFavoriteTagResponse: Codable {
    let httpCode: Int
    let httpStatus, responseMessage: String
}
