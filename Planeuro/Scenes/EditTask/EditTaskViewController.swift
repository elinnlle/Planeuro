import UIKit
import CoreData

@objcMembers
class EditTaskViewController: UIViewController, UITableViewDelegate, BottomBarManagerDelegate {
    func bottomBarManagerNewSubtask(_ manager: BottomBarManager) {}
    func bottomBarManagerAcceptSubtasks(_ manager: BottomBarManager) {}
    
    // MARK: - Constants
    
    private enum Constants {
        static let mainFontSize: CGFloat = 17
        static let titleFontSize: CGFloat = 27
        static let titleTopOffset: CGFloat = 20.0
        
        static let sideInset: CGFloat = 20
        static let titleTop: CGFloat = 16
        static let elementTopSpacing: CGFloat = 16
        static let elementSmallTopSpacing: CGFloat = 8
        static let reminderSmallTopSpacing: CGFloat = 5
        static let bottomInset: CGFloat = 20
            
        static let dateCollectionViewHeight: CGFloat = 190
        static let timeContainerHeight: CGFloat = 75
        static let locationSettingsHeight: CGFloat = 75
        static let categoryCollectionViewHeight: CGFloat = 30
        
        static let titleTapGestureMinimumPressDuration: TimeInterval = 0.3
    }
    
    // MARK: - Categories
    private var categories: [(title: String, color: UIColor, colorName: String)] = []
    private var selectedCategoryIndex: Int? = nil
    private let availableColors: [(displayName: String, colorName: String, uiColor: UIColor)] = [
        ("Красный", "red", .systemRed),
        ("Оранжевый", "orange", .systemOrange),
        ("Жёлтый", "yellow", .systemYellow),
        ("Зелёный", "green", .systemGreen),
        ("Синий", "blue", .systemBlue),
        ("Фиолетовый", "purple", .systemPurple),
        ("Серый", "gray", .systemGray),
        ("Коричневый", "brown", .brown)
    ]
    
    // MARK: - Dependencies
    weak var delegate: TaskEditorDelegate?
    public private(set) var bottomBarManager: BottomBarManager!
    private let shouldSaveToDB: Bool
    private let indexInParent: Int?
    
    // MARK: - Core Data / Model
    private var task: Tasks
    private let taskService = TasksService()
    
    // MARK: - Original values for change detection
    private var originalTaskTitle: String
    private var originalTaskAddress: String
    private var originalTaskStartDate: Date
    private var originalTaskEndDate: Date
    private var originalTaskTimeTravel: Int
    private var originalReminders: [String?]
    private var originalTaskCategoryColorName: String
    private var originalTaskCategoryTitle: String
    
    // Напоминания (до 2)
    private var reminders: [String?]
    
    private var isModified: Bool {
        return task.title != originalTaskTitle ||
               task.address != originalTaskAddress ||
               task.startDate != originalTaskStartDate ||
               task.endDate != originalTaskEndDate ||
               task.timeTravel != originalTaskTimeTravel ||
               reminders != originalReminders ||
               task.categoryColorName.lowercased() != originalTaskCategoryColorName.lowercased() ||
               task.categoryTitle != originalTaskCategoryTitle
    }
    
    // MARK: - UI Elements
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    
    private lazy var screenTitleLabel: UILabel = {
        let label = UILabel()
        label.text = task.title
        label.font = UIFont(name: "Nunito-ExtraBold", size: Constants.titleFontSize)
        label.textColor = .color800
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var dateHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Дата"
        label.font = UIFont(name: "Nunito-Regular", size: Constants.mainFontSize)
        label.textColor = .color700
        return label
    }()
    private lazy var dateCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(DateSettings.self, forCellWithReuseIdentifier: "DateSettings")
        cv.register(UICollectionReusableView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: "DownArrowView")
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private lazy var timeHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Время"
        label.font = UIFont(name: "Nunito-Regular", size: Constants.mainFontSize)
        label.textColor = .color700
        return label
    }()
    private lazy var timeContainerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.color500.cgColor
        view.layer.cornerRadius = 20
        return view
    }()
    private lazy var timeCell: TimeSettings = {
        let cell = TimeSettings()
        let leftTap = UITapGestureRecognizer(target: self, action: #selector(didTapStartTime))
        cell.startTimeLabel.addGestureRecognizer(leftTap)
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(didTapEndTime))
        cell.endTimeLabel.addGestureRecognizer(rightTap)
        return cell
    }()
    
    private lazy var locationHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Место"
        label.font = UIFont(name: "Nunito-Regular", size: Constants.mainFontSize)
        label.textColor = .color700
        return label
    }()
    private lazy var locationSettings: LocationSettings = {
        let view = LocationSettings()
        view.onEditLocation = { [weak self] in self?.presentLocationEditAlert() }
        return view
    }()
    
    private lazy var categoryHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = UIFont(name: "Nunito-Regular", size: Constants.mainFontSize)
        label.textColor = .color700
        return label
    }()
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(CategorySettings.self, forCellWithReuseIdentifier: "CategorySettings")
        cv.dataSource = self
        cv.delegate = self
        cv.allowsMultipleSelection = false
        return cv
    }()
    
    private lazy var reminderHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Напоминание"
        label.font = UIFont(name: "Nunito-Regular", size: Constants.mainFontSize)
        label.textColor = .color700
        return label
    }()
    private lazy var reminderSettings: ReminderSettings = {
        let view = ReminderSettings()
        view.onEditReminders = { [weak self] in self?.didTapReminderSettings() }
        return view
    }()
    
    // MARK: - Apple Calendar reminder options
    private static let appleCalendarReminders: [(String, TimeInterval)] = [
        ("В момент события", 0),
        ("За 5 минут", 5 * 60),
        ("За 10 минут", 10 * 60),
        ("За 15 минут", 15 * 60),
        ("За 30 минут", 30 * 60),
        ("За 1 час", 60 * 60),
        ("За 2 часа", 2 * 60 * 60),
        ("За 1 день", 24 * 60 * 60),
        ("За 2 дня", 2 * 24 * 60 * 60),
        ("За 1 неделю", 7 * 24 * 60 * 60)
    ]
    
    // MARK: - Initialization
    init(task: Tasks, shouldSaveToDB: Bool = true, indexInParent: Int? = nil) {
        self.task = task
        
        // Map existing offsets into reminder titles
        var mappedReminders: [String?] = [nil, nil]
        for (i, offset) in task.reminderOffsets.enumerated() where i < 2 {
            if let title = Self.appleCalendarReminders.first(where: { $0.1 == offset })?.0 {
                mappedReminders[i] = title
            } else if offset == 0 {
                mappedReminders[i] = "В момент события"
            }
        }
        self.reminders = mappedReminders
        self.originalReminders = mappedReminders
        
        self.originalTaskTitle = task.title
        self.originalTaskAddress = task.address
        self.originalTaskStartDate = task.startDate
        self.originalTaskEndDate = task.endDate
        self.originalTaskTimeTravel = task.timeTravel
        self.originalTaskCategoryColorName = task.categoryColorName
        self.originalTaskCategoryTitle = task.categoryTitle
        
        self.shouldSaveToDB = shouldSaveToDB
        self.indexInParent = indexInParent
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        populateFields()
        
        let config = BottomBarConfiguration(
                    icons: ["BackEditIcon", "TrashIcon"],
                    gradientImage: "GradientEdit"
                )
        bottomBarManager = BottomBarManager(view: view, configuration: config)
        bottomBarManager.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let titleTap = UITapGestureRecognizer(target: self, action: #selector(didTapTitle))
        screenTitleLabel.addGestureRecognizer(titleTap)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeToExit))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
        
        loadCategoriesFromDB()
        if let idx = categories.firstIndex(where: { $0.colorName.lowercased() == task.categoryColorName.lowercased() }) {
            selectedCategoryIndex = idx
        } else {
            selectedCategoryIndex = nil
        }
    }
    
    @objc private func handleSwipeToExit(_ gesture: UISwipeGestureRecognizer) {
        bottomBarManagerDidTapBack(bottomBarManager)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func didTapTitle() {
        let alert = UIAlertController(title: "Изменить название задачи", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = self.task.title
            tf.autocorrectionType = .yes
        }
        alert.addAction(.init(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Сохранить", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty, text != self.task.title {
                self.task.title = text
                self.screenTitleLabel.text = text
            }
        })
        present(alert, animated: true)
    }
    
    func presentLocationEditAlert() {
        let alert = UIAlertController(title: "Место", message: "Введите адрес и время на дорогу (необязтельно)", preferredStyle: .alert)
        alert.view.tintColor = .color700
            
        alert.addTextField { textField in
            textField.placeholder = "Адрес"
            textField.text = self.task.address
            textField.autocorrectionType = .yes
        }
        alert.addTextField { textField in
            textField.placeholder = "Минуты"
            textField.text = self.task.timeTravel > 0 ? "\(self.task.timeTravel)" : ""
            textField.keyboardType = .numberPad
        }
            
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default) { _ in
            guard let addressField = alert.textFields?[0],
                let travelField = alert.textFields?[1] else {
                return
            }
            let newAddress = addressField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let travelString = travelField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
            // Обновляем адрес
            if newAddress != self.task.address {
                self.task.address = newAddress
                self.locationSettings.updateAddress(newAddress)
            }
                
            // Обновляем время на дорогу
            if !travelString.isEmpty {
                if let minutes = Int(travelString), minutes >= 0 {
                    if minutes != self.task.timeTravel {
                        self.task.timeTravel = minutes
                        self.locationSettings.updateTravelTime(minutes)
                    }
                } else {
                    self.showErrorAlert(title: "Некорректное значение", message: "Введите корректное число минут.") {
                        self.presentLocationEditAlert()
                    }
                }
            } else {
                // Если поле пустое, обнулим
                self.task.timeTravel = 0
                self.locationSettings.updateTravelTime(0)
            }
        })
            
        present(alert, animated: true)
    }
    
    // MARK: - Reminder Logic
    @objc private func didTapReminderSettings() {
        let activeSlots = reminders.enumerated().compactMap { $0.element != nil ? $0.offset : nil }
        switch activeSlots.count {
        case 0:
            presentAppleCalendarMenu(forSlot: 0) {
                let confirm = UIAlertController(title: "Добавить второе напоминание?", message: nil, preferredStyle: .alert)
                confirm.view.tintColor = .color700
                confirm.addAction(.init(title: "Нет", style: .cancel))
                confirm.addAction(.init(title: "Да", style: .default) { _ in
                    self.presentAppleCalendarMenu(forSlot: 1)
                })
                self.present(confirm, animated: true)
            }
        case 1:
            let alert = UIAlertController(
                title: "Напоминание",
                message: "У вас уже есть одно напоминание. Изменить его или добавить второе?",
                preferredStyle: .alert
            )
            alert.view.tintColor = .color700
            alert.addAction(.init(title: "Изменить", style: .default) { _ in
                self.presentAppleCalendarMenu(forSlot: activeSlots.first!)
            })
            alert.addAction(.init(title: "Добавить второе", style: .default) { _ in
                self.presentAppleCalendarMenu(forSlot: 1)
            })
            alert.addAction(.init(title: "Отмена", style: .cancel))
            present(alert, animated: true)
        case 2:
            let alert = UIAlertController(
                title: "Изменить напоминание",
                message: "Какое напоминание изменить?",
                preferredStyle: .alert
            )
            alert.view.tintColor = .color700
            alert.addAction(.init(title: "Первое", style: .default) { _ in
                self.presentAppleCalendarMenu(forSlot: 0)
            })
            alert.addAction(.init(title: "Второе", style: .default) { _ in
                self.presentAppleCalendarMenu(forSlot: 1)
            })
            alert.addAction(.init(title: "Отмена", style: .cancel))
            present(alert, animated: true)
        default:
            break
        }
    }
    
    private func collapseDuplicateReminders() {
        if let r0 = reminders[0], let r1 = reminders[1], r0 == r1 {
            reminders[1] = nil
        }
    }
    
    private func presentAppleCalendarMenu(forSlot slot: Int, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Выберите напоминание", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Нет", style: .default) { _ in
            self.reminders[slot] = nil
            self.collapseDuplicateReminders()
            self.reminderSettings.reminders = self.reminders
            completion?()
        })
        alert.addAction(UIAlertAction(title: "В момент события", style: .default) { _ in
            if self.task.startDate < Date() {
                self.showErrorAlert(title: "Неверное напоминание", message: "Событие прошло – невозможно напомнить «в момент события».")
                return
            }
            self.reminders[slot] = "В момент события"
            self.collapseDuplicateReminders()
            self.reminderSettings.reminders = self.reminders
            completion?()
        })
        for (title, offset) in Self.appleCalendarReminders where title != "В момент события" {
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                let reminderDate = self.task.startDate.addingTimeInterval(-offset)
                if reminderDate < Date() {
                    self.showErrorAlert(title: "Неверное напоминание", message: "Дата срабатывания уже в прошлом.")
                    return
                }
                self.reminders[slot] = title
                self.collapseDuplicateReminders()
                self.reminderSettings.reminders = self.reminders
                completion?()
            })
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in completion?() })
        present(alert, animated: true)
    }
    
    // MARK: - Time pickers
    @objc func didTapStartTime() {
        presentCenteredOverlayPicker(mode: .time, initialDate: task.startDate) { [weak self] newDate in
            guard let self = self else { return }
            self.task.startDate = newDate
            if newDate > self.task.endDate {
                self.task.endDate = newDate
            }
            self.updateTimeCell()
        }
    }
    
    @objc func didTapEndTime() {
        presentCenteredOverlayPicker(mode: .time, initialDate: task.endDate) { [weak self] newDate in
            guard let self = self else { return }
            if newDate < self.task.startDate {
                self.showErrorAlert(title: "Неверное время", message: "Время окончания не может быть раньше времени начала.")
                return
            }
            self.task.endDate = newDate
            self.updateTimeCell()
        }
    }
    
    private func updateTimeCell() {
        let s = task.startDate.formatted(date: .omitted, time: .shortened)
        let e = task.endDate.formatted(date: .omitted, time: .shortened)
        timeCell.configureTimes(startTitle: "От", startValue: s, endTitle: "До", endValue: e)
    }
    
    // MARK: - BottomBarManagerDelegate
    func bottomBarManagerDidTapBack(_ manager: BottomBarManager) {
        // If editing a subtask
        if !shouldSaveToDB {
            if !isModified {
                delegate?.taskEditor(self, didFinishEditing: task, at: indexInParent)
                navigationController?.popViewController(animated: true)
                return
            }
            let alert = UIAlertController(title: "Сохранить изменения?", message: nil, preferredStyle: .alert)
            alert.view.tintColor = .color700
            alert.addAction(.init(title: "Сохранить", style: .default) { _ in
                // update reminders
                let newOffsets = self.reminders.compactMap { title in
                    title.flatMap { t in Self.appleCalendarReminders.first(where: { $0.0 == t })?.1 }
                }
                self.task.reminderOffsets = newOffsets
                self.delegate?.taskEditor(self, didFinishEditing: self.task, at: self.indexInParent)
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(.init(title: "Не сохранять", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            alert.addAction(.init(title: "Отмена", style: .cancel))
            present(alert, animated: true)
            return
        }
        // Main save logic
        if !isModified {
            navigationController?.popViewController(animated: true)
            return
        }
        let alert = UIAlertController(title: "Сохранить изменения?", message: "", preferredStyle: .alert)
        alert.view.tintColor = .color700
        alert.addAction(.init(title: "Сохранить", style: .default) { _ in
            // apply reminder changes
            let newOffsets = self.reminders.compactMap { title in
                title.flatMap { t in Self.appleCalendarReminders.first(where: { $0.0 == t })?.1 }
            }
            self.task.reminderOffsets = newOffsets
            
            // Перепланируем локальные уведомления и получаем новые ID
            let newNotificationIDs = NotificationManager
                .shared
                .scheduleLocalNotifications(for: self.task)
            // Обновляем в модели и сохраняем в Core Data
                self.task.reminderNotificationIDs = newNotificationIDs
                self.taskService.updateReminderIDs(for: self.task, with: newNotificationIDs)
            
            // update Core Data
            self.taskService.updateTask(self.task, originalTitle: self.originalTaskTitle)
            
            // calendar event update
            let calendarFieldsChanged =
                self.task.title != self.originalTaskTitle ||
                self.task.startDate != self.originalTaskStartDate ||
                self.task.endDate != self.originalTaskEndDate ||
                self.task.address != self.originalTaskAddress
            if calendarFieldsChanged, let eid = self.task.eventIdentifier, !eid.isEmpty {
                CalendarManager.shared.updateEvent(for: self.task, eventIdentifier: eid) { success, newEid in
                    if success, let newEid = newEid {
                        self.task.eventIdentifier = newEid
                    }
                }
            }
            // refresh originals
            self.originalTaskTitle = self.task.title
            self.originalTaskAddress = self.task.address
            self.originalTaskStartDate = self.task.startDate
            self.originalTaskEndDate = self.task.endDate
            self.originalTaskTimeTravel = self.task.timeTravel
            self.originalReminders = self.reminders
            self.originalTaskCategoryColorName = self.task.categoryColorName
            self.originalTaskCategoryTitle = self.task.categoryTitle
            
            NotificationCenter.default.post(name: NSNotification.Name("TasksUpdated"), object: nil)
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(.init(title: "Не сохранять", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(.init(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    func bottomBarManagerDidTapTrash(_ manager: BottomBarManager) {
        if !shouldSaveToDB {
            let alert = UIAlertController(title: "Удалить подзадачу?", message: "Вы уверены?", preferredStyle: .alert)
            alert.view.tintColor = .color700
            alert.addAction(.init(title: "Отмена", style: .cancel))
            alert.addAction(.init(title: "Удалить", style: .default) { _ in
                if let idx = self.indexInParent {
                    self.delegate?.taskEditorDidDelete(self, at: idx)
                }
                self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
            return
        }
        let alert = UIAlertController(title: "Удалить задачу?", message: "Вы уверены?", preferredStyle: .alert)
        alert.view.tintColor = .color700
        alert.addAction(.init(title: "Отмена", style: .cancel))
        alert.addAction(.init(title: "Удалить", style: .destructive) { _ in
            if let eid = self.task.eventIdentifier, !eid.isEmpty {
                CalendarManager.shared.deleteEvent(withIdentifier: eid) { _ in }
            }
            self.taskService.deleteTask(self.task)
            NotificationCenter.default.post(name: NSNotification.Name("TasksUpdated"), object: nil)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        scrollView = UIScrollView()
        scrollView.delegate = self
        view.addSubview(scrollView)
        contentView = UIView()
        scrollView.addSubview(contentView)
        
        [screenTitleLabel,
         dateHeaderLabel, dateCollectionView,
         timeHeaderLabel, timeContainerView,
         locationHeaderLabel, locationSettings,
         categoryHeaderLabel, categoryCollectionView,
         reminderHeaderLabel, reminderSettings].forEach {
            contentView.addSubview($0)
         }
        timeContainerView.addSubview(timeCell)
    }

    private func setupConstraints() {
        scrollView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        scrollView.pinLeft(to: view.leadingAnchor)
        scrollView.pinRight(to: view.trailingAnchor)
        scrollView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)

        contentView.pinTop(to: scrollView.topAnchor)
        contentView.pinLeft(to: scrollView.leadingAnchor)
        contentView.pinRight(to: scrollView.trailingAnchor)
        contentView.pinBottom(to: scrollView.bottomAnchor)
        contentView.pinWidth(to: scrollView)

        // title
        screenTitleLabel.pinTop(to: contentView.topAnchor, Constants.titleTop)
        screenTitleLabel.pinLeft(to: contentView.leadingAnchor, Constants.sideInset)
        screenTitleLabel.pinRight(to: contentView.trailingAnchor, Constants.sideInset)

        // date
        dateHeaderLabel.pinTop(to: screenTitleLabel.bottomAnchor, Constants.elementTopSpacing)
        dateHeaderLabel.pinLeft(to: contentView.leadingAnchor, Constants.sideInset)
        dateHeaderLabel.pinRight(to: contentView.trailingAnchor, Constants.sideInset)

        dateCollectionView.pinTop(to: dateHeaderLabel.bottomAnchor, Constants.elementSmallTopSpacing)
        dateCollectionView.pinLeft(to: contentView.leadingAnchor, Constants.sideInset)
        dateCollectionView.pinRight(to: contentView.trailingAnchor, Constants.sideInset)
        dateCollectionView.setHeight(Constants.dateCollectionViewHeight)

        // time
        timeHeaderLabel.pinTop(to: dateCollectionView.bottomAnchor, Constants.elementTopSpacing)
        timeHeaderLabel.pinLeft(to: contentView.leadingAnchor, Constants.sideInset)
        timeHeaderLabel.pinRight(to: contentView.trailingAnchor, Constants.sideInset)

        timeContainerView.pinTop(to: timeHeaderLabel.bottomAnchor, Constants.elementSmallTopSpacing)
        timeContainerView.pinLeft(to: contentView.leadingAnchor, Constants.sideInset)
        timeContainerView.pinRight(to: contentView.trailingAnchor, Constants.sideInset)
        timeContainerView.setHeight(Constants.timeContainerHeight)

        timeCell.pinTop(to: timeContainerView.topAnchor)
        timeCell.pinLeft(to: timeContainerView.leadingAnchor)
        timeCell.pinRight(to: timeContainerView.trailingAnchor)
        timeCell.pinBottom(to: timeContainerView.bottomAnchor)

        // location
        locationHeaderLabel.pinTop(to: timeContainerView.bottomAnchor, Constants.elementTopSpacing)
        locationHeaderLabel.pinLeft(to: contentView.leadingAnchor, Constants.sideInset)
        locationHeaderLabel.pinRight(to: contentView.trailingAnchor, Constants.sideInset)

        locationSettings.pinTop(to: locationHeaderLabel.bottomAnchor, Constants.elementSmallTopSpacing)
        locationSettings.pinLeft(to: contentView.leadingAnchor, Constants.sideInset)
        locationSettings.pinRight(to: contentView.trailingAnchor, Constants.sideInset)
        locationSettings.setHeight(Constants.locationSettingsHeight)

        // category
        categoryHeaderLabel.pinTop(to: locationSettings.bottomAnchor, Constants.elementTopSpacing)
        categoryHeaderLabel.pinLeft(to: contentView.leadingAnchor, Constants.sideInset)
        categoryHeaderLabel.pinRight(to: contentView.trailingAnchor, Constants.sideInset)

        categoryCollectionView.pinTop(to: categoryHeaderLabel.bottomAnchor, Constants.elementSmallTopSpacing)
        categoryCollectionView.pinLeft(to: contentView.leadingAnchor, Constants.sideInset)
        categoryCollectionView.pinRight(to: contentView.trailingAnchor, Constants.sideInset)
        categoryCollectionView.setHeight(Constants.categoryCollectionViewHeight)

        // reminder
        reminderHeaderLabel.pinTop(to: categoryCollectionView.bottomAnchor, Constants.elementTopSpacing)
        reminderHeaderLabel.pinLeft(to: contentView.leadingAnchor, Constants.sideInset)
        reminderHeaderLabel.pinRight(to: contentView.trailingAnchor, Constants.sideInset)

        reminderSettings.pinTop(to: reminderHeaderLabel.bottomAnchor, Constants.reminderSmallTopSpacing)
        reminderSettings.pinLeft(to: contentView.leadingAnchor, Constants.sideInset)
        reminderSettings.pinRight(to: contentView.trailingAnchor, Constants.sideInset)
        reminderSettings.pinBottom(to: contentView.bottomAnchor, Constants.bottomInset)
    }
    
    // MARK: - Populate Fields
    private func populateFields() {
        updateTimeCell()
        locationSettings.updateAddress(task.address)
        locationSettings.updateTravelTime(task.timeTravel)
        reminderSettings.reminders = reminders
    }
    
    // MARK: - Category Management
    private let userCategoriesKey = "UserTaskCategories"
    private let deletedDefaultCategoriesKey = "DeletedDefaultCategories"
    
    private func loadCategoriesFromDB() {
        categories.removeAll()
        let userCats = fetchUserCategoriesFromDB()
        userCats.forEach { cat in
            categories.append((cat.title, colorFromString(cat.colorName), cat.colorName.lowercased()))
        }
        let deleted = UserDefaults.standard.array(forKey: deletedDefaultCategoriesKey) as? [String] ?? []
        let defaults: [(String, UIColor, String)] = [
            ("Праздник", .systemYellow, "yellow"),
            ("Здоровье", .systemGreen, "green"),
            ("Работа", .systemBlue, "blue"),
            ("Другая", .systemGray, "gray")
        ]
        defaults.forEach { def in
            if !deleted.contains(def.2) && !categories.contains(where: { $0.colorName == def.2 }) {
                categories.append(def)
            }
        }
        categoryCollectionView.reloadData()
    }
    private func fetchUserCategoriesFromDB() -> [(title: String, colorName: String)] {
        guard let saved = UserDefaults.standard.array(forKey: userCategoriesKey) as? [[String:String]] else {
            return []
        }
        return saved.compactMap { dict in
            if let t = dict["title"], let c = dict["colorName"] {
                return (t, c)
            }
            return nil
        }
    }
    private func saveUserCategoryToDB(title: String, colorName: String) {
        var current = fetchUserCategoriesFromDB()
        if let idx = current.firstIndex(where: { $0.colorName == colorName }) {
            current[idx] = (title, colorName)
        } else {
            current.append((title, colorName))
        }
        let arr = current.map { ["title": $0.title, "colorName": $0.colorName] }
        UserDefaults.standard.set(arr, forKey: userCategoriesKey)
    }
    private func deleteUserCategoryFromDB(title: String, colorName: String) {
        let lower = colorName.lowercased()
        let defaults = ["yellow","green","blue","gray"]
        if defaults.contains(lower) {
            var deleted = UserDefaults.standard.array(forKey: deletedDefaultCategoriesKey) as? [String] ?? []
            if !deleted.contains(lower) {
                deleted.append(lower)
                UserDefaults.standard.set(deleted, forKey: deletedDefaultCategoriesKey)
            }
        } else {
            var current = fetchUserCategoriesFromDB()
            if let idx = current.firstIndex(where: { $0.title == title && $0.colorName.lowercased() == lower }) {
                current.remove(at: idx)
                let arr = current.map { ["title": $0.title, "colorName": $0.colorName] }
                UserDefaults.standard.set(arr, forKey: userCategoriesKey)
            }
        }
    }
    private func colorFromString(_ name: String) -> UIColor {
        switch name.lowercased() {
        case "red": return .systemRed
        case "orange": return .systemOrange
        case "yellow": return .systemYellow
        case "green": return .systemGreen
        case "blue": return .systemBlue
        case "purple": return .systemPurple
        case "gray": return .systemGray
        case "brown": return .brown
        default: return .white
        }
    }
    
    private func presentAddOrEditCategory(isNew: Bool, indexToEdit: Int? = nil, prefilledTitle: String? = nil) {
        var currentTitle = ""
        var currentColor = availableColors.first?.colorName ?? "red"
        if !isNew, let idx = indexToEdit {
            let cat = categories[idx]
            currentTitle = cat.title
            currentColor = cat.colorName
        } else {
            currentTitle = prefilledTitle ?? ""
        }
        let alert = UIAlertController(
            title: isNew ? "Новая категория" : "Изменить категорию",
            message: "Введите название и выберите цвет",
            preferredStyle: .alert
        )
        alert.view.tintColor = .color700
        alert.addTextField { tf in
            tf.placeholder = "Название категории"
            tf.text = currentTitle
            tf.autocorrectionType = .yes
        }
        alert.addTextField { tf in
            if let disp = self.availableColors.first(where: { $0.colorName == currentColor })?.displayName {
                tf.text = disp
            }
            tf.inputView = self.makeColorPicker(currentSelectedColorName: currentColor) { newColor in
                currentColor = newColor
                if let disp = self.availableColors.first(where: { $0.colorName == newColor })?.displayName {
                    tf.text = disp
                }
            }
            tf.autocorrectionType = .no
        }
        if !isNew {
            alert.addAction(.init(title: "Удалить", style: .destructive) { _ in
                if let idx = indexToEdit {
                    let old = self.categories[idx]
                    self.deleteUserCategoryFromDB(title: old.title, colorName: old.colorName)
                    self.categories.remove(at: idx)
                    if self.selectedCategoryIndex == idx {
                        self.selectedCategoryIndex = nil
                        self.task.categoryColorName = ""
                        self.task.categoryTitle = ""
                    } else if let sel = self.selectedCategoryIndex, sel > idx {
                        self.selectedCategoryIndex = sel - 1
                    }
                    self.categoryCollectionView.reloadData()
                    self.taskService.removeCategoryFromTasks(color: old.colorName)
                }
            })
        }
        alert.addAction(.init(title: "Отмена", style: .cancel))
        alert.addAction(.init(title: "Сохранить", style: .default) { _ in
            guard let newTitle = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newTitle.isEmpty else {
                self.showErrorAlert(title: "Ошибка", message: "Название не должно быть пустым.")
                return
            }
            var conflict: Int?
            for (i, cat) in self.categories.enumerated() {
                if let edit = indexToEdit, edit == i { continue }
                if cat.colorName == currentColor {
                    conflict = i; break
                }
            }
            if let c = conflict {
                let cat = self.categories[c]
                let ca = UIAlertController(
                    title: "Обнаружен конфликт",
                    message: "Цвет уже используется категорией \"\(cat.title)\"",
                    preferredStyle: .alert
                )
                ca.view.tintColor = .color700
                ca.addAction(.init(title: "Изменить \"\(cat.title)\"", style: .default) { _ in
                    self.categories[c] = (newTitle, self.colorFromString(currentColor), currentColor)
                    self.saveUserCategoryToDB(title: newTitle, colorName: currentColor)
                    self.selectedCategoryIndex = c
                    self.task.categoryColorName = currentColor
                    self.task.categoryTitle = newTitle
                    self.categoryCollectionView.reloadData()
                })
                ca.addAction(.init(title: "Изменить выбранный", style: .default) { _ in
                    self.presentAddOrEditCategory(isNew: isNew, indexToEdit: indexToEdit, prefilledTitle: newTitle)
                })
                ca.addAction(.init(title: "Отмена", style: .cancel))
                self.present(ca, animated: true)
                return
            }
            self.saveUserCategoryToDB(title: newTitle, colorName: currentColor)
            let uiColor = self.colorFromString(currentColor)
            if isNew {
                self.categories.append((newTitle, uiColor, currentColor))
                self.selectedCategoryIndex = self.categories.count - 1
                self.task.categoryColorName = currentColor
                self.task.categoryTitle = newTitle
            } else if let idx = indexToEdit {
                self.categories[idx] = (newTitle, uiColor, currentColor)
                if self.selectedCategoryIndex == idx {
                    self.task.categoryColorName = currentColor
                    self.task.categoryTitle = newTitle
                }
            }
            self.categoryCollectionView.reloadData()
        })
        present(alert, animated: true)
    }
    
    private func makeColorPicker(currentSelectedColorName: String, didSelectColor: @escaping (String) -> Void) -> UIView {
        class DataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
            let colors: [(String, String, UIColor)]
            let select: (String) -> Void
            init(colors: [(String, String, UIColor)], select: @escaping (String) -> Void) {
                self.colors = colors; self.select = select
            }
            func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
            func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
                colors.count
            }
            func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
                colors[row].0
            }
            func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                select(colors[row].1)
            }
            func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                            forComponent component: Int, reusing view: UIView?) -> UIView {
                let stack = UIStackView()
                stack.axis = .horizontal; stack.alignment = .center; stack.spacing = 8
                let circle = UIView()
                circle.backgroundColor = colors[row].2
                circle.layer.cornerRadius = 10
                circle.layer.masksToBounds = true
                circle.translatesAutoresizingMaskIntoConstraints = false
                circle.widthAnchor.constraint(equalToConstant: 20).isActive = true
                circle.heightAnchor.constraint(equalToConstant: 20).isActive = true
                let lbl = UILabel(); lbl.text = colors[row].0
                stack.addArrangedSubview(circle)
                stack.addArrangedSubview(lbl)
                return stack
            }
            func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
                return 50
            }
        }
        let picker = UIPickerView()
        let ds = DataSource(colors: availableColors, select: didSelectColor)
        picker.dataSource = ds
        picker.delegate = ds
        if let idx = availableColors.firstIndex(where: { $0.colorName == currentSelectedColorName }) {
            picker.selectRow(idx, inComponent: 0, animated: false)
        }
        objc_setAssociatedObject(picker, &AssociatedKeys.colorPickerDataSource, ds, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return picker
    }
    private struct AssociatedKeys { static var colorPickerDataSource = "colorPickerDataSource" }
    
    // MARK: - Alerts & Pickers
    private func showErrorAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = .color700
        alert.addAction(.init(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
    
    private func presentCenteredOverlayPicker(
        mode: UIDatePicker.Mode,
        initialDate: Date,
        completion: @escaping (Date) -> Void
    ) {
        let titleText = (mode == .date) ? "Выберите дату" : "Выберите время"
        let style: UIAlertController.Style = (mode == .date) ? .actionSheet : .alert
        let alert = UIAlertController(title: titleText, message: "\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: style)
        alert.view.tintColor = .color700
        let picker = UIDatePicker()
        picker.datePickerMode = mode
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ru_RU")
        picker.date = initialDate
        alert.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        if mode == .date {
            NSLayoutConstraint.activate([
                picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 40),
                picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 20),
                picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -20),
                picker.heightAnchor.constraint(equalToConstant: 216)
            ])
        } else {
            NSLayoutConstraint.activate([
                picker.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                picker.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor)
            ])
        }
        alert.addAction(.init(title: mode == .date ? "Выбрать" : "OK", style: .default) { _ in
            completion(picker.date)
        })
        alert.addAction(.init(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & DelegateFlowLayout
extension EditTaskViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionView == dateCollectionView ? 2 : 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == dateCollectionView { return 4 }
        return categories.count + 1
    }
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if collectionView == dateCollectionView,
           kind == UICollectionView.elementKindSectionFooter,
           indexPath.section == 0 {
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "DownArrowView",
                for: indexPath
            )
            let arrow = DateSettings.createDownArrowView()
            footer.addSubview(arrow)
            arrow.frame = footer.bounds
            return footer
        }
        return UICollectionReusableView()
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        if collectionView == dateCollectionView && section == 0 {
            return CGSize(width: collectionView.bounds.width, height: 40)
        }
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == dateCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DateSettings",
                for: indexPath
            ) as! DateSettings
            let isStart = indexPath.section == 0
            let base = isStart ? task.startDate : task.endDate
            switch indexPath.item {
            case 0:
                if let d = Calendar.current.date(byAdding: .day, value: -1, to: base) {
                    if !isStart && d < task.startDate {
                        cell.configureDate(d, referenceDate: base)
                        cell.updateCellSelectedState(false)
                    } else {
                        cell.configureDate(d, referenceDate: base)
                    }
                }
            case 1:
                cell.configureDate(base, referenceDate: base)
            case 2:
                if let d = Calendar.current.date(byAdding: .day, value: 1, to: base) {
                    cell.configureDate(d, referenceDate: base)
                }
            case 3:
                cell.configure(dayNumber: "Иная", dayName: "Дата")
                cell.updateCellSelectedState(false)
            default: break
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CategorySettings",
                for: indexPath
            ) as! CategorySettings
            if indexPath.item < categories.count {
                let cat = categories[indexPath.item]
                cell.configure(with: cat.title, color: cat.color)
                if selectedCategoryIndex == indexPath.item {
                    cell.contentView.layer.borderWidth = 2
                    cell.contentView.layer.borderColor = cat.color.cgColor
                } else {
                    cell.contentView.layer.borderWidth = 0
                }
                cell.contentView.tag = indexPath.item
                cell.contentView.gestureRecognizers?.forEach { cell.contentView.removeGestureRecognizer($0) }
                let longPress = UILongPressGestureRecognizer(
                    target: self,
                    action: #selector(handleCategoryLongPress(_:))
                )
                longPress.minimumPressDuration = Constants.titleTapGestureMinimumPressDuration
                cell.contentView.addGestureRecognizer(longPress)
            } else {
                cell.configureAsAddButton(color: .color500)
                cell.contentView.layer.borderWidth = 0
            }
            return cell
        }
    }
    @objc private func handleCategoryLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let idx = gesture.view?.tag,
              idx < categories.count else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        presentAddOrEditCategory(isNew: false, indexToEdit: idx)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == dateCollectionView {
            let isStart = indexPath.section == 0
            let base = isStart ? task.startDate : task.endDate
            switch indexPath.item {
            case 0:
                if let nd = Calendar.current.date(byAdding: .day, value: -1, to: base) {
                    if !isStart && nd < task.startDate {
                        showErrorAlert(title: "Неверная дата",
                                       message: "Дата окончания не может быть раньше даты начала задачи.")
                        return
                    }
                    if isStart {
                        task.startDate = nd
                        if task.startDate > task.endDate { task.endDate = nd }
                    } else {
                        task.endDate = nd
                    }
                }
            case 2:
                if let nd = Calendar.current.date(byAdding: .day, value: 1, to: base) {
                    if !isStart && nd < task.startDate {
                        showErrorAlert(title: "Неверная дата",
                                       message: "Дата окончания не может быть раньше даты начала задачи.")
                        return
                    }
                    if isStart {
                        task.startDate = nd
                        if task.startDate > task.endDate { task.endDate = nd }
                    } else {
                        task.endDate = nd
                    }
                }
            case 3:
                presentCenteredOverlayPicker(mode: .date, initialDate: base) { sd in
                    if !isStart && sd < self.task.startDate {
                        self.showErrorAlert(title: "Неверная дата",
                                            message: "Дата окончания не может быть раньше даты начала задачи.")
                        return
                    }
                    if isStart {
                        self.task.startDate = sd
                        if sd > self.task.endDate { self.task.endDate = sd }
                    } else {
                        self.task.endDate = sd
                    }
                    self.dateCollectionView.reloadData()
                }
            default: break
            }
            collectionView.reloadData()
        } else {
            if indexPath.item < categories.count {
                if selectedCategoryIndex == indexPath.item {
                    selectedCategoryIndex = nil
                    task.categoryColorName = ""
                    task.categoryTitle = ""
                } else {
                    selectedCategoryIndex = indexPath.item
                    let cat = categories[indexPath.item]
                    task.categoryColorName = cat.colorName
                    task.categoryTitle = cat.title
                }
                collectionView.reloadData()
            } else {
                presentAddOrEditCategory(isNew: true)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == dateCollectionView {
            return CGSize(width: 75, height: 75)
        } else {
            if indexPath.item < categories.count {
                let text = categories[indexPath.item].title
                let w = text.size(withAttributes: [.font: UIFont(name: "Nunito-Regular", size: 14)!]).width
                return CGSize(width: w + 40, height: 30)
            }
            return CGSize(width: 40, height: 30)
        }
    }
}
