import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    // MARK: - Private Properties
    
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private let presenter = MovieQuizPresenter()
    private var correctAnswers: Int = .zero
    
    private var moviesLoader: MoviesLoader = MoviesLoader()
    private var statisticService: StatisticService = StatisticServiceImplementation()
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var gamesCount: Int = .zero
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadDataFromServer(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else { return }
        changeStateButton(isEnabled:false)
        showAnswerResult(isCorrect: true == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else { return }
        changeStateButton(isEnabled:false)
        showAnswerResult(isCorrect: false == !currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    
    
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            self.presenter.resetCurrentQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.presentAlert(with: model)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func saveGameResults(correct: Int, total: Int) {
        statisticService.store(correct: correct, total: total)
    }
    
    private func showNextQuestionOrResults() {
        changeStateButton(isEnabled: true)
        if presenter.isLastQuestion() {
            saveGameResults(correct: correctAnswers, total: presenter.questionsAmount)
            let text = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)\n" +
            "Количество сыгранных квизов:\(statisticService.gamesCount)\n" +
            "Рекорд:\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)(\(statisticService.bestGame.date.dateTimeString))\n" +
            "Средняя точность:\(String(format: "%.2f", statisticService.totalAccuracy))%"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = nil
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion:{ [weak self] in
                guard let self else { return }
                
                self.presenter.resetCurrentQuestionIndex()
                self.correctAnswers = 0
                self.imageView.layer.borderWidth = 0
                self.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter.presentAlert(with: alertModel)
    }
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
}

