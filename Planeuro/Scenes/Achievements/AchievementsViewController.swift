//
//  AchievementsViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 09.04.2025.
//

import UIKit

class AchievementsViewController: UIViewController {

    // MARK: – UI Элементы

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let levelLabel = UILabel()
    public var bottomBarManager: BottomBarManager!

    // MARK: – Child VCs & Data

    private var taskAchievements: [Achievement]    = []
    private var visitorAchievements: [Achievement] = []
    private let tasksVC    = TasksAchievementsViewController()
    private let visitorsVC = FrequentVisitorAchievementsViewController()

    // MARK: – Константы

    private enum Constants {
        // отступы
        static let sideInset: CGFloat      = 20
        static let sectionSpacing: CGFloat = 24
        static let headerSpacing: CGFloat  = 8
        static let innerPadding: CGFloat   = 16

        // профиль
        static let profileSize: CGFloat = 70

        // контейнеры
        static let containerCorner: CGFloat = 12
        static let containerBorder: CGFloat = 1

        // бейджи
        static let badgeSpacing: CGFloat      = 20
        static let circleSize: CGFloat        = 90
        static let progressBarWidth: CGFloat  = 90
        static let progressBarHeight: CGFloat = 7

        // плашки
        static let pillHeight: CGFloat = 30
        static let pillwidth: CGFloat = 110

        // шрифты
        static let nameFontSize: CGFloat    = 27
        static let headerFontSize: CGFloat  = 17
        static let badgeTitleFontSize: CGFloat = 13
        static let badgeCountFontSize: CGFloat = 12
    }

    // MARK: – Жизненный цикл

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        reloadData()

        let cfg = BottomBarConfiguration(
            icons: ["HomeIconAdd","CalendarIconAdd","SettingsIconAdd"],
            gradientImage: ""
        )
        bottomBarManager = BottomBarManager(view: view, configuration: cfg)
        scrollView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    // MARK: – UI Setup

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        scrollView.pinLeft(to: view.leadingAnchor)
        scrollView.pinRight(to: view.trailingAnchor)
        scrollView.pinBottom(to: view.bottomAnchor)
        
        contentView.pinTop(to: scrollView.topAnchor)
        contentView.pinLeft(to: scrollView.leadingAnchor)
        contentView.pinRight(to: scrollView.trailingAnchor)
        contentView.pinBottom(to: scrollView.bottomAnchor)
        contentView.setWidth(view.bounds.width)

        setupProfileSection()
    }

    private func setupProfileSection() {
        // аватар
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = Constants.profileSize / 2
        profileImageView.clipsToBounds = true
        contentView.addSubview(profileImageView)

        // имя пользователя
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont(name: "Nunito-ExtraBold", size: Constants.nameFontSize)
        nameLabel.textColor = .color800
        contentView.addSubview(nameLabel)

        // уровень
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.font = UIFont(name: "Nunito-Regular", size: Constants.headerFontSize)
        levelLabel.textColor = .black
        levelLabel.layer.borderWidth = Constants.containerBorder
        levelLabel.layer.borderColor = UIColor.color500.cgColor
        levelLabel.backgroundColor = .white
        levelLabel.layer.cornerRadius = Constants.pillHeight / 2
        levelLabel.layer.masksToBounds = true
        levelLabel.textAlignment = .center
        contentView.addSubview(levelLabel)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.sideInset),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.profileSize),
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.profileSize),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: Constants.headerSpacing),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            levelLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.headerSpacing),
            levelLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            levelLabel.heightAnchor.constraint(equalToConstant: Constants.pillHeight),
            levelLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.pillwidth),
        ])

        // загрузка данных профиля
        if let data = UserDefaults.standard.data(forKey: "userPhoto"),
           let img = UIImage(data: data) {
            profileImageView.image = img
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = .color500
        }
        nameLabel.text = UserDefaults.standard.string(forKey: "userName") ?? "Имя пользователя"
    }

    // MARK: – Data Loading

    private func reloadData() {
        taskAchievements    = tasksVC.topAchievements(count: 3)
        visitorAchievements = visitorsVC.topAchievements(count: 3)

        let doneCount = (taskAchievements + visitorAchievements)
            .filter { $0.progress >= 1.0 }
            .count
        levelLabel.text = "Уровень \(1 + doneCount)"

        populateSections()
    }

    // MARK: – Sections Layout

    private func populateSections() {
        // очищаем старые секции
        contentView.subviews
            .filter { $0.tag == 999 }
            .forEach { $0.removeFromSuperview() }

        let tasksHeader = makeHeader(title: "Выполнение задач", action: #selector(showAllTasks))
        let tasksBox    = makeBadgesContainer(for: taskAchievements)
        let visHeader   = makeHeader(title: "Постоянный посетитель", action: #selector(showAllVisitors))
        let visBox      = makeBadgesContainer(for: visitorAchievements)

        [tasksHeader, tasksBox, visHeader, visBox].forEach {
            $0.tag = 999
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            tasksHeader.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: Constants.sectionSpacing),
            tasksHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInset),
            tasksHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInset),

            tasksBox.topAnchor.constraint(equalTo: tasksHeader.bottomAnchor, constant: Constants.headerSpacing),
            tasksBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInset),
            tasksBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInset),

            visHeader.topAnchor.constraint(equalTo: tasksBox.bottomAnchor, constant: Constants.sectionSpacing),
            visHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInset),
            visHeader.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInset),

            visBox.topAnchor.constraint(equalTo: visHeader.bottomAnchor, constant: Constants.headerSpacing),
            visBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.sideInset),
            visBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.sideInset),
            visBox.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.sectionSpacing),
        ])
    }

    private func makeHeader(title: String, action: Selector) -> UIView {
        let container = UIView()
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = title
        lbl.font = UIFont(name: "Nunito-Regular", size: Constants.headerFontSize)
        lbl.textColor = .black

        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Показать все", for: .normal)
        btn.titleLabel?.font = UIFont(name: "Nunito-Regular", size: Constants.headerFontSize)
        btn.tintColor = .color800
        btn.addTarget(self, action: action, for: .touchUpInside)

        [lbl, btn].forEach { container.addSubview($0) }

        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: container.topAnchor),
            lbl.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            lbl.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            btn.centerYAnchor.constraint(equalTo: lbl.centerYAnchor),
            btn.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        return container
    }

    private func makeBadgesContainer(for list: [Achievement]) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = Constants.containerCorner
        container.layer.borderWidth = Constants.containerBorder
        container.layer.borderColor = UIColor.color500.cgColor
        container.backgroundColor = .white

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .top
        stack.spacing = Constants.badgeSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        list.forEach { stack.addArrangedSubview(makeBadgeView($0)) }
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: Constants.innerPadding),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Constants.innerPadding),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Constants.innerPadding),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -Constants.innerPadding),
        ])

        return container
    }

    private func makeBadgeView(_ ach: Achievement) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = Constants.circleSize / 2
        circle.backgroundColor = .color300

        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        imgView.isHidden = ach.imageName == nil
        if let name = ach.imageName { imgView.image = UIImage(named: name) }

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont(name: "Nunito-Regular", size: Constants.badgeTitleFontSize)
        title.textColor = .color800
        title.textAlignment = .center
        title.numberOfLines = 2
        let parts = ach.title.split(separator: " ")
        title.text = parts.count >= 2
            ? "\(parts[0])\n\(parts[1])"
            : "\(ach.title)\n"

        let progress = UIProgressView(progressViewStyle: .default)
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.layer.cornerRadius = Constants.progressBarHeight / 2
        progress.clipsToBounds = true
        progress.trackTintColor = .color300
        progress.tintColor = .color500
        progress.setProgress(ach.progress, animated: false)

        let countLabel = UILabel()
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = UIFont(name: "Nunito-Regular", size: Constants.badgeCountFontSize)
        countLabel.textColor = .color500
        countLabel.textAlignment = .center
        countLabel.text = ach.progressText

        [circle, imgView, title, progress, countLabel].forEach {
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            // круглая подложка
            circle.topAnchor.constraint(equalTo: view.topAnchor),
            circle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circle.widthAnchor.constraint(equalToConstant: Constants.circleSize),
            circle.heightAnchor.constraint(equalToConstant: Constants.circleSize),

            // иконка внутри круга
            imgView.topAnchor.constraint(equalTo: circle.topAnchor),
            imgView.leadingAnchor.constraint(equalTo: circle.leadingAnchor),
            imgView.trailingAnchor.constraint(equalTo: circle.trailingAnchor),
            imgView.bottomAnchor.constraint(equalTo: circle.bottomAnchor),

            // заголовок бейджа
            title.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: Constants.headerSpacing),
            title.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // прогресс-бар
            progress.topAnchor.constraint(equalTo: title.bottomAnchor, constant: Constants.headerSpacing),
            progress.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progress.widthAnchor.constraint(equalToConstant: Constants.progressBarWidth),
            progress.heightAnchor.constraint(equalToConstant: Constants.progressBarHeight),

            // текст прогресса
            countLabel.topAnchor.constraint(equalTo: progress.bottomAnchor, constant: 4),
            countLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            countLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            countLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        return view
    }

    // MARK: – Navigation

    @objc private func showAllTasks() {
        navigationController?.pushViewController(tasksVC, animated: true)
    }

    @objc private func showAllVisitors() {
        navigationController?.pushViewController(visitorsVC, animated: true)
    }
}

