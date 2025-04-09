//
//  TasksAchievementsViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 09.04.2025.
//

import UIKit

class TasksAchievementsViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let titleText: String              = "Выполнение задач"
        static let titleFontName: String          = "Nunito-ExtraBold"
        static let titleFontSize: CGFloat         = 27
        static let titleTopOffset: CGFloat        = 20
        static let horizontalPadding: CGFloat     = 15
        static let verticalPadding: CGFloat       = 15
        static let interItemPadding: CGFloat      = 5
        static let itemsPerRow: CGFloat           = 3
        static let progressLabelHeight: CGFloat   = 70
        static let bottomCollectionInset: CGFloat = 5
        static let iconsPrefix: String            = "T"
        static let achievementsTargets: [Int]     = [
            10, 30, 50, 100, 150, 200, 250,
            300, 350, 400, 450, 500, 750, 1000
        ]
        static let achievementsTitles: [String]   = [
            "Первые шаги", "Упорный трудяга", "Мастер задач",
            "Нацеленный на успех", "Планировщик в действии",
            "Стратег успеха", "Гуру продуктивности",
            "Покоритель планов", "Магистр эффективности",
            "Мастер многозадачности", "Великий организатор",
            "Профессионал планирования",
            "Супергерой планирования", "Легенда планирования"
        ]
    }

    // MARK: - UI Elements

    private let screenTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constants.titleText
        label.font = UIFont(name: Constants.titleFontName,
                            size: Constants.titleFontSize)
        label.textColor = .color800
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.interItemPadding
        layout.minimumInteritemSpacing = Constants.interItemPadding
        layout.sectionInset = UIEdgeInsets(
            top: Constants.interItemPadding,
            left: Constants.horizontalPadding,
            bottom: Constants.interItemPadding,
            right: Constants.horizontalPadding
        )

        let cv = UICollectionView(frame: .zero,
                                  collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.register(AchievementCell.self,
                    forCellWithReuseIdentifier: AchievementCell.reuseId)
        return cv
    }()

    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var collectionHeightConstraint: NSLayoutConstraint!

    // MARK: - Data

    private let taskInteractor = TaskInteractor()
    private var achievements: [Achievement] = []

    // MARK: - Bottom Bar

    public private(set) var bottomBarManager: BottomBarManager!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupBottomBar()
        scrollView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAchievements()
        updateCollectionHeight()
        collectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateItemSize()
    }

    // MARK: - Setup

    private func setupUI() {
        // Добавляем ScrollView и контейнер
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Добавляем заголовок и коллекцию
        contentView.addSubview(screenTitleLabel)
        contentView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Заголовок
            screenTitleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.titleTopOffset
            ),
            screenTitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.horizontalPadding
            ),
            screenTitleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.horizontalPadding
            ),

            // Коллекция
            collectionView.topAnchor.constraint(
                equalTo: screenTitleLabel.bottomAnchor,
                constant: Constants.verticalPadding
            ),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        // Ограничение высоты коллекции
        collectionHeightConstraint = collectionView.heightAnchor.constraint(
            equalToConstant: calculateCollectionHeight()
        )
        collectionHeightConstraint.isActive = true

        // Отступ снизу фиксирует контент
        collectionView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -Constants.bottomCollectionInset
        ).isActive = true
    }

    private func setupBottomBar() {
        let config = BottomBarConfiguration(
            icons: ["HomeIconAdd", "CalendarIconAdd", "BackIcon"],
            gradientImage: "Gradient"
        )
        bottomBarManager = BottomBarManager(view: view, configuration: config)
    }

    // MARK: - Data Loading

    private func loadAchievements() {
        let completedCount = taskInteractor
            .fetchTasks()
            .filter { $0.status == .completed }
            .count

        achievements = zip(Constants.achievementsTitles,
                           Constants.achievementsTargets)
            .enumerated()
            .map { index, pair in
                let (title, target) = pair
                let done = min(completedCount, target)
                let progress = Float(done) / Float(target)
                let imageName: String? = progress >= 1
                    ? "\(Constants.iconsPrefix)\(index + 1)"
                    : nil
                return Achievement(
                    title: title,
                    progress: progress,
                    progressText: "\(done) / \(target)",
                    imageName: imageName
                )
            }
    }

    /// Возвращает первые `count` достижений
    func topAchievements(count: Int = 3) -> [Achievement] {
        loadAchievements()
        return Array(achievements.prefix(count))
    }

    // MARK: - Layout Calculations
    private func updateCollectionHeight() {
        let newHeight = calculateCollectionHeight()
        collectionHeightConstraint.constant = newHeight
    }

    private func updateItemSize() {
        guard let layout = collectionView.collectionViewLayout
                as? UICollectionViewFlowLayout else { return }

        let totalPadding = Constants.interItemPadding * (Constants.itemsPerRow + 1)
        let availableWidth = view.bounds.width
            - totalPadding
            - 2 * Constants.horizontalPadding
        let itemWidth = availableWidth / Constants.itemsPerRow
        layout.itemSize = CGSize(
            width: itemWidth,
            height: itemWidth + Constants.progressLabelHeight
        )
        layout.invalidateLayout()
    }

    private func calculateCollectionHeight() -> CGFloat {
        let count = achievements.count
        let rows = ceil(CGFloat(count) / Constants.itemsPerRow)

        let totalPaddingHorizontal = Constants.interItemPadding * (Constants.itemsPerRow + 1)
        let availableWidth = view.bounds.width
            - totalPaddingHorizontal
            - 2 * Constants.horizontalPadding
        let itemWidth = availableWidth / Constants.itemsPerRow
        let itemHeight = itemWidth + Constants.progressLabelHeight

        return rows * itemHeight
            + (rows + 1) * Constants.interItemPadding
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension TasksAchievementsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        achievements.count
    }

    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let achievement = achievements[indexPath.item]
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: AchievementCell.reuseId,
            for: indexPath
        ) as! AchievementCell
        cell.configure(with: achievement)
        return cell
    }
}
