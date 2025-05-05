import UIKit

final class MovieQuizViewController: UIViewController {
   
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
    
    private var moviesLoader: MoviesLoader = MoviesLoader()
    private var statisticService: StatisticService = StatisticServiceImplementation()
    var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var gamesCount: Int = .zero

    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadDataFromServer(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - IB Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Public Methods
    
    func showAnswerResult(isCorrect: Bool) {
       presenter.didAnswer(isCorrect: isCorrect)
        
       imageView.layer.masksToBounds = true
       imageView.layer.borderWidth = 8
       imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
       
       DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
           guard let self else { return }
           self.presenter.showNextQuestionOrResults()
           self.presenter.questionFactory = self.questionFactory
       }
   }
    
     func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
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
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func resetImageViewStyle() {
        imageView.layer.borderWidth = 0
        imageView.image = nil
    }
    
    func setButtonsEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
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
}

