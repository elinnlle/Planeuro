//
//  MainViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, TaskPresenterDelegate {

    // MARK: - Свойства
    
    private var tasks: [Task] = []
    private let presenter = TaskPresenter()
    private let categories = ["Все", "Активные", "Выполненные", "Просроченные"]
    private var filteredTasks: [Task] = []
    public private(set) var bottomBarManager: BottomBarManager!
    
    // MARK: - Константы
    
    private enum Constants {
        static let collectionViewLineSpacing: CGFloat = 10.0
        static let collectionViewSectionInsetRight: CGFloat = 20.0
        static let titleFontSize: CGFloat = 27.0
        static let dateFontSize: CGFloat = 17.0
        static let tableViewRowHeight: CGFloat = 106.0
        static let buttonSize: CGFloat = 40.0
        static let titleTopOffset: CGFloat = 20.0
        static let titleWidth: CGFloat = 245.0
        static let titleHeight: CGFloat = 30.0
        static let dateTopOffset: CGFloat = 2.0
        static let dateHeight: CGFloat = 21.0
        static let addButtonTopOffset: CGFloat = 23.0
        static let addButtonSize: CGFloat = 45.0
        static let collectionViewTopOffset: CGFloat = 16.0
        static let collectionViewBottomOffset: CGFloat = -56.0
        static let collectionViewLeftOffset: CGFloat = 20.0
        static let collectionViewRightOffset: CGFloat = 10.0
        static let collectionViewHeight: CGFloat = 40.0
    }
    
    // MARK: - UI Элементы
    
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Constants.collectionViewLineSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: Constants.collectionViewSectionInsetRight)
            
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        return collectionView
    }()
    
    private let tableView = UITableView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Список задач"
        label.font = UIFont(name: "Nunito-ExtraBold", size: Constants.titleFontSize)
        label.textColor = .color800
        label.textAlignment = .left
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Nunito-Regular", size: Constants.dateFontSize)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.clipsToBounds = true
        if let plusImage = UIImage(named: "PlusIcon") {
            button.setImage(plusImage, for: .normal)
        }
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()


    // MARK: - Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Список задач"

        setupUI()
        setupTableView()
        
        presenter.delegate = self
        presenter.loadTasks()
        
        updateDateLabel()
        
        bottomBarManager = BottomBarManager(view: view)
    }

    // Синхронизируем дату с реальной
    private func updateDateLabel() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeek = dateFormatter.string(from: currentDate).capitalized
        
        dateFormatter.dateFormat = "d MMMM"
        let date = dateFormatter.string(from: currentDate)
        
        dateLabel.text = "\(dayOfWeek), \(date)"
    }

    // MARK: - Настройка UI
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(dateLabel)
        view.addSubview(addButton)
        view.addSubview(categoryCollectionView)
        
        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.titleTopOffset)
        titleLabel.pinLeft(to: view, Constants.collectionViewLeftOffset)
        titleLabel.setWidth(mode: .equal, Constants.titleWidth)
        titleLabel.setHeight(mode: .equal, Constants.titleHeight)

        dateLabel.pinTop(to: titleLabel.bottomAnchor, Constants.dateTopOffset)
        dateLabel.pinLeft(to: view, Constants.collectionViewLeftOffset)
        dateLabel.setWidth(mode: .equal, Constants.titleWidth)
        dateLabel.setHeight(mode: .equal, Constants.dateHeight)

        addButton.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.addButtonTopOffset)
        addButton.pinRight(to: view, Constants.collectionViewRightOffset)
        addButton.setWidth(mode: .equal, Constants.addButtonSize)
        addButton.setHeight(mode: .equal, Constants.addButtonSize)

        categoryCollectionView.pinTop(to: dateLabel.bottomAnchor, Constants.collectionViewTopOffset)
        categoryCollectionView.pinLeft(to: view.leadingAnchor, Constants.collectionViewLeftOffset)
        categoryCollectionView.pinRight(to: view.trailingAnchor, Constants.collectionViewRightOffset)
        categoryCollectionView.setHeight(mode: .equal, Constants.collectionViewHeight)
        categoryCollectionView.pinBottom(to: dateLabel.bottomAnchor, Constants.collectionViewBottomOffset)
        
        // Настройка таблицы
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.rowHeight = Constants.tableViewRowHeight
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        view.addSubview(tableView)

        // Установка ограничений таблицы
        tableView.pinTop(to: categoryCollectionView.bottomAnchor, Constants.collectionViewTopOffset)
        tableView.pinLeft(to: view)
        tableView.pinRight(to: view)
        tableView.pinBottom(to: view)
    }

    // MARK: - Настройка таблицы
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.frame = view.bounds
        tableView.rowHeight = Constants.tableViewRowHeight
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        tableView.pinTop(to: categoryCollectionView.bottomAnchor, Constants.collectionViewTopOffset)
        tableView.pinLeft(to: view.leadingAnchor)
        tableView.pinRight(to: view.trailingAnchor)
        tableView.pinBottom(to: view.bottomAnchor)
    }

    func updateTasks(_ tasks: [Task]) {
        self.tasks = tasks
        filterTasks(by: categories[selectedCategoryIndex])
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }

        let task = filteredTasks[indexPath.row]
        cell.configure(with: task)
        return cell
    }


    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = filteredTasks[indexPath.row]
        
        // Действие для завершения задачи
        let completeAction = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
            let taskIndex = self.tasks.firstIndex(where: { $0.title == task.title })!
            self.tasks[taskIndex].isActive = false
            self.filteredTasks[indexPath.row].isActive = false
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.updateCategoryCounts()
            completionHandler(true)
        }
        completeAction.backgroundColor = .white
        completeAction.image = UIImage(named: "CheckmarkIcon")

        // Действие для удаления задачи
        /// Так как необходимо было подвинуть иконку удаления подальше от правого края, но не было возможности настроить ширину контейнера, пришлось увеличивать её текстом, а иконку вручную накладывать на белый фон и сдвигать вниз
        let deleteAction = UIContextualAction(style: .destructive, title: "TraashIcon") { (action, view, completionHandler) in
            let taskIndex = self.tasks.firstIndex(where: { $0.title == task.title })!
            self.tasks.remove(at: taskIndex)
            self.filteredTasks.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateCategoryCounts()
            completionHandler(true)
        }
        deleteAction.backgroundColor = .white
        deleteAction.image = UIImage(named: "TrashIcon")

        // Создание конфигурации действий
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
        return configuration
    }

    
    private func updateCategoryCounts() {
        for index in 0..<categories.count {
            let category = categories[index]
            let taskCount = taskCount(for: category)
            
            if let cell = categoryCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CategoryCell {
                cell.configure(with: category, taskCount: taskCount, isSelected: index == selectedCategoryIndex)
            }
        }
    }

    // MARK: - UICollectionViewDelegate & UICollectionViewDataSource
    
    private var selectedCategoryIndex: Int = 0

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.row]
        let taskCount = taskCount(for: category)
        cell.configure(with: category, taskCount: taskCount, isSelected: indexPath.row == selectedCategoryIndex)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategoryIndex = indexPath.row
        filterTasks(by: categories[indexPath.row])
        collectionView.reloadData()
    }

    // MARK: - Фильтрация задач
    
    private func filterTasks(by category: String) {
        switch category {
        case "Все":
            filteredTasks = tasks
        case "Активные":
            filteredTasks = tasks.filter { $0.isActive }
        case "Выполненные":
            filteredTasks = tasks.filter { !$0.isActive }
        case "Просроченные":
            filteredTasks = tasks // Потом исправим
        default:
            break
        }
        tableView.reloadData()
    }
    
    private func taskCount(for category: String) -> Int {
        switch category {
        case "Все":
            return tasks.count
        case "Активные":
            return tasks.filter { $0.isActive }.count
        case "Выполненные":
            return tasks.filter { !$0.isActive }.count
        case "Просроченные":
            return 0 // Потом исправим
        default:
            return 0
        }
    }
    
    // MARK: - Добавление задач
    @objc private func addButtonTapped() {
        let addTaskVC = AddTaskViewController()
        navigationController?.pushViewController(addTaskVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let category = categories[indexPath.item]
        let taskCount = taskCount(for: category)
        return CategoryCell.size(for: category, taskCount: taskCount)
    }
}

