//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Андрей Васенков on 5.04.25.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               
    func didReceiveNextQuestion(question: QuizQuestion?)
}
