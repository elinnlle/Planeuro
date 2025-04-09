//
//  MainViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, TaskPresenterDelegate {

    // MARK: - Свойства
    private var tasks: [Tasks] = []
    private let presenter = TaskPresenter()
    private let statuses = ["Все", "Активные", "Выполненные", "Просроченные"]
    private var filteredTasks: [Tasks] = []
    private let taskService = TasksService()
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
    private lazy var satusCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = Constants.collectionViewLineSpacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: Constants.collectionViewSectionInsetRight)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SatusCell.self, forCellWithReuseIdentifier: "SatusCell")
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
        setupUI()
        setupTableView()
        
        presenter.delegate = self
        
        // Подписываемся на уведомление об обновлении задач
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tasksUpdatedNotification),
                                               name: NSNotification.Name("TasksUpdated"),
                                               object: nil)
        
        // Если база пуста – заполняем тестовыми данными
        let service = TasksService()
        let currentTasks = service.getAllTasks()
        if currentTasks.isEmpty {
            saveTasksFromJSON()
        }
        presenter.loadTasks()
        updateDateLabel()
        
        bottomBarManager = BottomBarManager(view: view)
    }

    @objc private func tasksUpdatedNotification() {
        // Перезагружаем задачи сразу после получения уведомления
        presenter.loadTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        presenter.loadTasks()
      }
    
    // Обновление даты
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
        view.addSubview(satusCollectionView)
        
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
        
        satusCollectionView.pinTop(to: dateLabel.bottomAnchor, Constants.collectionViewTopOffset)
        satusCollectionView.pinLeft(to: view.leadingAnchor, Constants.collectionViewLeftOffset)
        satusCollectionView.pinRight(to: view.trailingAnchor, Constants.collectionViewRightOffset)
        satusCollectionView.setHeight(mode: .equal, Constants.collectionViewHeight)
        satusCollectionView.pinBottom(to: dateLabel.bottomAnchor, Constants.collectionViewBottomOffset)
        
        // Настройка таблицы
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.rowHeight = Constants.tableViewRowHeight
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.pinTop(to: satusCollectionView.bottomAnchor, Constants.collectionViewTopOffset)
        tableView.pinLeft(to: view)
        tableView.pinRight(to: view)
        tableView.pinBottom(to: view)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.frame = view.bounds
        tableView.rowHeight = Constants.tableViewRowHeight
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        tableView.pinTop(to: satusCollectionView.bottomAnchor, Constants.collectionViewTopOffset)
        tableView.pinLeft(to: view.leadingAnchor)
        tableView.pinRight(to: view.trailingAnchor)
        tableView.pinBottom(to: view.bottomAnchor)
    }
    
    func updateTasks(_ tasks: [Tasks]) {
        // Фильтруем задачи: оставляем только те, у которых задана категория
        let tasksWithCategory = tasks.filter { task in
            let trimmed = task.categoryColorName.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty && trimmed.lowercased() != "white"
        }
        
        // Сортируем задачи по дате начала (по возрастанию)
        self.tasks = tasksWithCategory.sorted { $0.startDate < $1.startDate }
        
        // Применяем фильтрацию по статусу ("Все", "Активные" и т.д.)
        filterTasks(by: statuses[selectedStatusIndex])
        updateStatusCounts()
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
    
    // Обработка нажатия на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = filteredTasks[indexPath.row]
        let editTaskVC = EditTaskViewController(task: selectedTask)
        navigationController?.pushViewController(editTaskVC, animated: true)
    }
    
    // Используем действия свайпа через делегат, вызываем методы презентера
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = filteredTasks[indexPath.row]
        
        // Действие для завершения задачи
        let completeAction = UIContextualAction(style: .normal, title: "") { (_, _, completionHandler) in
            self.presenter.completeTask(task)
            completionHandler(true)
        }
        completeAction.backgroundColor = .white
        completeAction.image = UIImage(named: "CheckmarkIcon")
        
        let deleteAction = UIContextualAction(style: .destructive, title: "DeleteIcon") { (_, _, completionHandler) in
            let alert = UIAlertController(title: "Удалить задачу?",
                                          message: "Вы уверены, что хотите удалить задачу?",
                                          preferredStyle: .alert)
            
            // Отмена удаления
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in
                completionHandler(false)
            })
            
            // Подтверждение удаления
            alert.addAction(UIAlertAction(title: "Удалить", style: .default) { _ in
                // Если у задачи есть связанное событие в календаре, удаляем его
                if let eventID = task.eventIdentifier, !eventID.isEmpty {
                    CalendarManager.shared.deleteEvent(withIdentifier: eventID) { success in
                        if !success {
                            print("Не удалось удалить событие из календаря")
                        }
                    }
                }
                
                // Удаляем задачу из базы данных
                self.taskService.deleteTask(task)
                
                // Отправляем уведомление для обновления списка задач
                NotificationCenter.default.post(name: NSNotification.Name("TasksUpdated"), object: nil)
                
                completionHandler(true)
            })
            
            self.present(alert, animated: true, completion: nil)
        }
        deleteAction.backgroundColor = .white
        deleteAction.image = UIImage(named: "DeleteIcon")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
        return configuration
    }


    
    private func updateStatusCounts() {
        for index in 0..<statuses.count {
            let status = statuses[index]
            let taskCount = taskCount(for: status)
            if let cell = satusCollectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SatusCell {
                cell.configure(with: status, taskCount: taskCount, isSelected: index == selectedStatusIndex)
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate & UICollectionViewDataSource
    private var selectedStatusIndex: Int = 0
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statuses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SatusCell", for: indexPath) as? SatusCell else {
            return UICollectionViewCell()
        }
        let status = statuses[indexPath.row]
        let taskCount = taskCount(for: status)
        cell.configure(with: status, taskCount: taskCount, isSelected: indexPath.row == selectedStatusIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedStatusIndex = indexPath.row
        filterTasks(by: statuses[indexPath.row])
        collectionView.reloadData()
    }
    
    // MARK: - Фильтрация задач
    private func filterTasks(by status: String) {
        // 1. Отбираем по статусу
        switch status {
        case "Все":
            filteredTasks = tasks
        case "Активные":
            filteredTasks = tasks.filter { $0.status == .active }
        case "Выполненные":
            filteredTasks = tasks.filter { $0.status == .completed }
        case "Просроченные":
            filteredTasks = tasks.filter { $0.status == .overdue }
        default:
            filteredTasks = []
        }

        // 2. Сортируем так, чтобы «прошлые» (выполненные/просроченные и с датой старше текущей) шли в конец
        let now = Date()
        filteredTasks.sort { a, b in
            // Флаг, что задача уже «в прошлом»
            let aIsPast = ( (a.status == .completed || a.status == .overdue) && a.startDate < now )
            let bIsPast = ( (b.status == .completed || b.status == .overdue) && b.startDate < now )
            
            // Если одна из них прошлое, она должна быть позже
            if aIsPast != bIsPast {
                return !aIsPast
            }
            // Иначе — по возрастанию даты старта
            return a.startDate < b.startDate
        }

        tableView.reloadData()
    }

    
    private func taskCount(for status: String) -> Int {
        switch status {
        case "Все":
            return tasks.count
        case "Активные":
            return tasks.filter { $0.status == .active }.count
        case "Выполненные":
            return tasks.filter { $0.status == .completed }.count
        case "Просроченные":
            return tasks.filter { $0.status == .overdue }.count
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
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let status = statuses[indexPath.item]
        let taskCount = taskCount(for: status)
        return SatusCell.size(for: status, taskCount: taskCount)
    }
}
