//
//  FrequentVisitorAchievementsViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 09.04.2025.
//

import UIKit

class FrequentVisitorAchievementsViewController: UIViewController {

    // MARK: – Constants

    private enum Constants {
        // отступы и размеры
        static let titleFontSize: CGFloat     = 27
        static let titleTopOffset: CGFloat    = 20
        static let horizontalPadding: CGFloat = 15
        static let interItemPadding: CGFloat  = 5
        static let itemsPerRow: CGFloat       = 3

        // расчёт высоты ячейки
        static let extraCellHeight: CGFloat   = 70
    }

    // MARK: – Icons

    private let iconPrefix = "FV"  // префикс имён в Assets

    // MARK: – Data

    private(set) var achievements: [Achievement] = []

    // MARK: – UI Elements

    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var collectionHeightConstraint: NSLayoutConstraint!
    public private(set) var bottomBarManager: BottomBarManager!

    private let screenTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Постоянный посетитель"
        label.font = UIFont(name: "Nunito-ExtraBold", size: Constants.titleFontSize)
        label.textColor = .color800
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .zero  // задаём в viewDidLayoutSubviews()
        layout.minimumLineSpacing = Constants.interItemPadding
        layout.minimumInteritemSpacing = Constants.interItemPadding
        layout.sectionInset = UIEdgeInsets(
            top: Constants.interItemPadding,
            left: Constants.horizontalPadding,
            bottom: Constants.interItemPadding,
            right: Constants.horizontalPadding
        )

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.register(AchievementCell.self,
                    forCellWithReuseIdentifier: AchievementCell.reuseId)
        return cv
    }()

    // MARK: – Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()

        let config = BottomBarConfiguration(
            icons: ["HomeIconAdd", "CalendarIconAdd", "BackIcon"],
            gradientImage: "Gradient"
        )
        bottomBarManager = BottomBarManager(view: view, configuration: config)
        scrollView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAchievements()
        updateCollectionHeight()
        collectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // пересчёт размера ячеек по ширине экрана
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let totalPadding = Constants.interItemPadding * (Constants.itemsPerRow + 1)
        let itemWidth = (view.bounds.width
                         - totalPadding
                         - 2 * Constants.horizontalPadding)
                        / Constants.itemsPerRow
        layout.itemSize = CGSize(
            width: itemWidth,
            height: itemWidth + Constants.extraCellHeight
        )
        layout.invalidateLayout()
    }

    // MARK: – Data Setup

    private func setupAchievements() {
        let visitCount = VisitManager.shared.totalVisits
        let targets = [1, 3, 7, 14, 30, 60, 90, 120, 180, 365, 400, 500, 600, 750, 1000]
        let titles = [
            "Стартовая точка","Триумф первых дней","Недельный марафон",
            "Две недели продуктивности","Месяц продуктивности",
            "Долгосрочный планировщик","Три месяца на высоте",
            "Шаг к постоянству","Полгода продуктивности",
            "Годовой рекордсмен","Непрерывный прогресс",
            "Великий организатор","Эксперт по времени",
            "Ветеран планирования","Легенда продуктивности"
        ]

        achievements = zip(titles, targets)
            .enumerated()
            .map { index, pair in
                let (title, target) = pair
                let done = min(visitCount, target)
                let progress = Float(done) / Float(target)
                let imageName: String? = (progress >= 1.0)
                    ? "\(iconPrefix)\(index + 1)"
                    : nil
                return Achievement(
                    title: title,
                    progress: progress,
                    progressText: "\(done) / \(target)",
                    imageName: imageName
                )
            }
    }

    // Возвращает первые `count` достижений
    func topAchievements(count: Int = 3) -> [Achievement] {
        setupAchievements()
        return Array(achievements.prefix(count))
    }

    // MARK: – UI Setup

    private func setupUI() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        contentView.addSubview(screenTitleLabel)
        contentView.addSubview(collectionView)

        NSLayoutConstraint.activate([
            // scrollView заполняет экран
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // contentView повторяет ширину scrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // заголовок
            screenTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.titleTopOffset),
            screenTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            screenTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),

            // collectionView
            collectionView.topAnchor.constraint(equalTo: screenTitleLabel.bottomAnchor, constant: Constants.interItemPadding),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        // фиксированная высота
        collectionHeightConstraint = collectionView.heightAnchor.constraint(
            equalToConstant: calculateCollectionHeight()
        )
        collectionHeightConstraint.isActive = true

        // привязка низа
        collectionView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -Constants.interItemPadding
        ).isActive = true
    }

    private func updateCollectionHeight() {
        collectionHeightConstraint.constant = calculateCollectionHeight()
    }

    private func calculateCollectionHeight() -> CGFloat {
        let count = achievements.count
        let rows = ceil(CGFloat(count) / Constants.itemsPerRow)
        let totalPadding = Constants.interItemPadding * (Constants.itemsPerRow + 1)
        let itemWidth = (view.bounds.width
                         - totalPadding
                         - 2 * Constants.horizontalPadding)
                        / Constants.itemsPerRow
        let itemHeight = itemWidth + Constants.extraCellHeight
        return rows * itemHeight + (rows + 1) * Constants.interItemPadding
    }
}

// MARK: – UICollectionViewDataSource, UICollectionViewDelegate

extension FrequentVisitorAchievementsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        achievements.count
    }

    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let model = achievements[indexPath.item]
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: AchievementCell.reuseId,
            for: indexPath
        ) as! AchievementCell
        cell.configure(with: model)
        return cell
    }
}

// MARK: – VisitManager

class VisitManager {
    static let shared = VisitManager()
    private let key = "visitedDates"

    private var dates: [Date] {
        get {
            (UserDefaults.standard.array(forKey: key) as? [Date])?
                .map { Calendar.current.startOfDay(for: $0) } ?? []
        }
        set {
            let days = newValue.map { Calendar.current.startOfDay(for: $0) }
            UserDefaults.standard.set(days, forKey: key)
        }
    }

    func recordVisit() {
        let today = Calendar.current.startOfDay(for: Date())
        if !dates.contains(today) {
            dates.append(today)
        }
    }

    /// Общее число дней посещения
    var totalVisits: Int { dates.count }

    /// Текущая серия дней подряд
    var currentStreak: Int {
        var streak = 0
        var day = Calendar.current.startOfDay(for: Date())
        while dates.contains(day) {
            streak += 1
            guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }
}
