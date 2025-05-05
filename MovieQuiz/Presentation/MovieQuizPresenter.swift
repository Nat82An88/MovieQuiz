import UIKit

final class MovieQuizPresenter {
    
    // MARK: - Public Properties
    
    var correctAnswers: Int = .zero
    let questionsAmount: Int = 10
    var questionFactory: QuestionFactoryProtocol?
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    // MARK: - Private Properties

    private var currentQuestionIndex: Int = .zero
   
    
    // MARK: - Public Methods
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetCurrentQuestionIndex() {
        currentQuestionIndex = .zero
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
     func saveGameResults(correct: Int, total: Int) {
        statisticService.store(correct: correct, total: total)
    }
    
     func showNextQuestionOrResults() {
        changeStateButton(isEnabled: true)
        if self.isLastQuestion() {
            saveGameResults(correct: correctAnswers, total: self.questionsAmount)
            let text = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)\n" +
            "Количество сыгранных квизов:\(statisticService.gamesCount)\n" +
            "Рекорд:\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)(\(statisticService.bestGame.date.dateTimeString))\n" +
            "Средняя точность:\(String(format: "%.2f", statisticService.totalAccuracy))%"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            viewController?.resetImageViewStyle()
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func changeStateButton(isEnabled: Bool) {
        viewController?.setButtonsEnabled(isEnabled)
   }
    // MARK: - Private Methods
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        let giveAnswer = isYes
        viewController?.showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
    }
}



