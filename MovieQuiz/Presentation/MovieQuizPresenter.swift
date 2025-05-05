import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Public Properties
    
    var correctAnswers: Int = .zero
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    
    // MARK: - Private Properties
    
    private let statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    weak var viewController: MovieQuizViewController?
    private var currentQuestionIndex: Int = .zero
   
    // MARK: - Initializers
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    // MARK: - Public Methods
    
    func yesButtonClicked() {
        didAnswer(isCorrect: true)
    }
    
    func noButtonClicked() {
        didAnswer(isCorrect: false)
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

    func didAnswer(isCorrect: Bool) {
        guard let currentQuestion else { return }
        let giveAnswer = isCorrect
        viewController?.showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
    }
}



