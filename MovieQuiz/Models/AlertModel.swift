//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Андрей Васенков on 6.04.25.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
