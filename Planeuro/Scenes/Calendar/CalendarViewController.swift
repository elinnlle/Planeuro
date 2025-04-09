//
//  CalendarViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 03.02.2025.
//

import UIKit

final class CalendarViewController: UIViewController {
    
    // MARK: - Константы
    
    private enum Constants {
        // Заголовок
        static let titleFontSize: CGFloat = 27.0
        static let titleTopOffset: CGFloat = 20.0
        static let titleHeight: CGFloat = 30.0
        static let collectionViewLeftOffset: CGFloat = 20.0
        static let monthButtonRightOffset: CGFloat = 10.0
        
        // Дни недели
        static let daysOfWeekStackViewTopOffset: CGFloat = 20.0
        static let daysOfWeekStackViewLeftOffset: CGFloat = 10.0
        static let daysOfWeekStackViewRightOffset: CGFloat = 10.0
        
        // Календарь
        static let calendarCollectionViewTopOffset: CGFloat = 10.0
        static let calendarCollectionViewLeftOffset: CGFloat = 10.0
        static let calendarCollectionViewRightOffset: CGFloat = 10.0
        
        // Ползунок календаря
        static let calendarHandleViewWidth: CGFloat = 64.0
        static let calendarHandleViewHeight: CGFloat = 3.0
        static let calendarHandleViewTopOffset: CGFloat = 8.0
        
        // DatePicker
        static let datePickerHeight: CGFloat = 216.0
        static let datePickerTopOffset: CGFloat = 40.0
        static let datePickerLeftOffset: CGFloat = 20.0
        static let datePickerRightOffset: CGFloat = 20.0
        
        // Константы для UICollectionView
        static let numberOfDaysInWeek: Int = 7
        static let daysInWeek: CGFloat = 7.0
        
        // Дополнительные константы
        static let minimumInteritemSpacing: CGFloat = 0
        static let minimumLineSpacing: CGFloat = 0
        static let swipeThreshold: CGFloat = 30.0
        static let animationDuration: TimeInterval = 0.3
        static let defaultCalendarHeight: CGFloat = 300.0
        static let labelFontSize: CGFloat = 17.0
        static let cornerRadius: CGFloat = 2.5
        static let previousMonthOffset: Int = -1
        static let nextMonthOffset: Int = 1
        static let monday: Int = 2
    }
    
    // MARK: - Свойства
    
    private var currentDate = Date()
    private(set) var selectedDate: Date?
    private var calendarHeightConstraint: NSLayoutConstraint?
    private var isCalendarCollapsed = false
    private let scheduleViewController = ScheduleViewController()
    
    // MARK: - UI Элементы
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Nunito-ExtraBold", size: Constants.titleFontSize)
        label.textColor = .color800
        label.textAlignment = .left
        return label
    }()
    
    private lazy var datePickerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "DownArrowIcon"), for: .normal)
        button.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        return button
    }()
    
    private lazy var prevMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "LeftArrowIcon"), for: .normal)
        button.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "RightArrowIcon"), for: .normal)
        button.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        return button
    }()
    
    private lazy var daysOfWeekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.minimumInteritemSpacing
        layout.minimumLineSpacing = Constants.minimumLineSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var calendarHandleView: UIView = {
        let view = LargeHitAreaView()
        view.backgroundColor = .color800
        view.layer.cornerRadius = Constants.cornerRadius
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCalendarPanGesture(_:)))
        view.addGestureRecognizer(panGesture)
        return view
    }()
    
    // MARK: - Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCurrentDate()
        setupUI()
        updateTitle()
        setupScheduleView()
        
        scheduleViewController.loadTasks(for: selectedDate ?? Date())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCalendarHeight()
    }
}

// MARK: - Настройка UI

extension CalendarViewController {
    private func setupUI() {
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
        setupDaysOfWeek()
        addSwipeGestures()
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(datePickerButton)
        view.addSubview(prevMonthButton)
        view.addSubview(nextMonthButton)
        view.addSubview(daysOfWeekStackView)
        view.addSubview(calendarCollectionView)
        view.addSubview(calendarHandleView)
    }
    
    private func setupScheduleView() {
        addChild(scheduleViewController)
        view.addSubview(scheduleViewController.view)
        scheduleViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scheduleViewController.view.topAnchor.constraint(equalTo: calendarHandleView.bottomAnchor, constant: 10),
            scheduleViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scheduleViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scheduleViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scheduleViewController.didMove(toParent: self)
    }
    
    private func setupConstraints() {
        // Настройка заголовка
        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.titleTopOffset)
        titleLabel.pinLeft(to: view, Constants.collectionViewLeftOffset)
        titleLabel.setHeight(mode: .equal, Constants.titleHeight)

        // Настройка стрелки выбора даты
        datePickerButton.pinCenterY(to: titleLabel.centerYAnchor)
        datePickerButton.pinLeft(to: titleLabel.trailingAnchor, Constants.monthButtonRightOffset)

        // Настройка кнопок переключения месяцев
        prevMonthButton.pinCenterY(to: titleLabel.centerYAnchor)
        prevMonthButton.pinRight(to: nextMonthButton.leadingAnchor, Constants.monthButtonRightOffset)
        nextMonthButton.pinCenterY(to: titleLabel.centerYAnchor)
        nextMonthButton.pinRight(to: view.trailingAnchor, Constants.monthButtonRightOffset)

        // Настройка дней недели
        daysOfWeekStackView.pinTop(to: titleLabel.bottomAnchor, Constants.daysOfWeekStackViewTopOffset)
        daysOfWeekStackView.pinLeft(to: view.leadingAnchor, Constants.daysOfWeekStackViewLeftOffset)
        daysOfWeekStackView.pinRight(to: view.trailingAnchor, Constants.daysOfWeekStackViewRightOffset)

        // Настройка календаря
        calendarCollectionView.pinTop(to: daysOfWeekStackView.bottomAnchor, Constants.calendarCollectionViewTopOffset)
        calendarCollectionView.pinLeft(to: view.leadingAnchor, Constants.calendarCollectionViewLeftOffset)
        calendarCollectionView.pinRight(to: view.trailingAnchor, Constants.calendarCollectionViewRightOffset)

        calendarHeightConstraint = calendarCollectionView.heightAnchor
            .constraint(
                equalToConstant: Constants.defaultCalendarHeight
            )
        calendarHeightConstraint?.isActive = true

        calendarHandleView.pinTop(to: calendarCollectionView.bottomAnchor, Constants.calendarHandleViewTopOffset)
        calendarHandleView.pinCenterX(to: view.centerXAnchor)
        calendarHandleView.setWidth(mode: .equal, Constants.calendarHandleViewWidth)
        calendarHandleView.setHeight(mode: .equal, Constants.calendarHandleViewHeight)
    }
    
    private func setupDaysOfWeek() {
        let daysOfWeek = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"]
        daysOfWeek.forEach { day in
            let label = UILabel()
            label.text = day
            label.font = UIFont(name: "NunitoSans-Regular", size: Constants.labelFontSize)
            label.textColor = .color800
            label.textAlignment = .center
            daysOfWeekStackView.addArrangedSubview(label)
        }
    }
    
    // Добавляем свайп-жесты для смены месяцев
    private func addSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        calendarCollectionView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        calendarCollectionView.addGestureRecognizer(swipeRight)
    }
}

// MARK: - Логика календаря

extension CalendarViewController {
    private func setupCurrentDate() {
        let calendar = Calendar.current
        currentDate = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        selectedDate = Date()
    }
    
    private func updateTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: currentDate)
        
        let monthNames = [
            "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь",
            "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"
        ]
        
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "ru_RU")
        monthFormatter.dateFormat = "M"
        let monthIndex = (Int(monthFormatter.string(from: currentDate)) ?? 1) - 1
        
        titleLabel.text = "\(monthNames[monthIndex]) \(yearString)"
    }
    
    private func updateCalendarHeight() {
        let availableWidth = calendarCollectionView.bounds.width
        let cellWidth = availableWidth / Constants.daysInWeek
        let weeks = numberOfWeeks(for: currentDate)
        let newHeight = isCalendarCollapsed ? cellWidth : cellWidth * CGFloat(weeks)
        calendarHeightConstraint?.constant = newHeight
    }
    
    private func numberOfWeeks(for date: Date) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = Constants.monday
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numberOfDays = range.count
        
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        let dayOffset = (
            weekdayOfFirstDay - calendar.firstWeekday + Constants.numberOfDaysInWeek
        ) % Constants.numberOfDaysInWeek
        
        let totalCells = numberOfDays + dayOffset
        return Int(ceil(Double(totalCells) / Constants.daysInWeek))
    }
}

// MARK: - Обработка жестов и действий

extension CalendarViewController {
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            nextMonth()
        } else if gesture.direction == .right {
            prevMonth()
        }
    }
    
    @objc private func handleCalendarPanGesture(_ gesture: UIPanGestureRecognizer) {
        if gesture.state == .ended {
            let translation = gesture.translation(in: view)
            if translation.y < -1 * Constants.swipeThreshold && !isCalendarCollapsed {
                collapseCalendar()
            } else if translation.y > Constants.swipeThreshold && isCalendarCollapsed {
                expandCalendar()
            }
        }
    }
    
    @objc private func showDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ru_RU")
        
        let alert = UIAlertController(title: "Выберите дату",
                                      message: "\n\n\n\n\n\n\n\n\n\n\n",
                                      preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker)
        
        datePicker.pinTop(to: alert.view.topAnchor, Constants.datePickerTopOffset)
        datePicker.pinLeft(to: alert.view.leadingAnchor, Constants.datePickerLeftOffset)
        datePicker.pinRight(to: alert.view.trailingAnchor, Constants.datePickerRightOffset)
        datePicker.setHeight(mode: .equal, Constants.datePickerHeight)
        
        let selectAction = UIAlertAction(title: "Выбрать", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let normalizedDate = Calendar.current.date(
                from: Calendar.current.dateComponents([.year, .month], from: datePicker.date)
            ) {
                self.currentDate = normalizedDate
            }
            self.selectedDate = datePicker.date
            self.updateTitle()
            self.calendarCollectionView.reloadData()
            
            if self.isCalendarCollapsed, let selected = self.selectedDate {
                self.scrollToWeek(containing: selected)
            }
            
            self.scheduleViewController.loadTasks(for: datePicker.date)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(selectAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func prevMonth() {
        currentDate = Calendar.current.date(
            byAdding: .month,
            value: Constants.previousMonthOffset,
            to: currentDate
        ) ?? currentDate
        updateTitle()
        calendarCollectionView.reloadData()
    }
    
    @objc private func nextMonth() {
        currentDate = Calendar.current.date(
            byAdding: .month,
            value: Constants.nextMonthOffset,
            to: currentDate
        ) ?? currentDate
        updateTitle()
        calendarCollectionView.reloadData()
    }
    
    private func collapseCalendar() {
        guard !isCalendarCollapsed else { return }
        isCalendarCollapsed = true
        updateCalendarHeight()
        
        if let selected = selectedDate {
            scrollToWeek(containing: selected)
        }
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func expandCalendar() {
        guard isCalendarCollapsed else { return }
        isCalendarCollapsed = false
        updateCalendarHeight()
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func scrollToWeek(containing date: Date) {
        let calendar = Calendar.current
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))
        else { return }
        
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        let dayOffset = (
            weekdayOfFirstDay - calendar.firstWeekday + Constants.numberOfDaysInWeek
        ) % Constants.numberOfDaysInWeek
        
        let selectedDay = calendar.component(.day, from: date)
        let dayIndex = dayOffset + (selectedDay - 1)
        
        let row = dayIndex / Constants.numberOfDaysInWeek
        let availableWidth = calendarCollectionView.bounds.width
        let cellHeight = availableWidth / Constants.daysInWeek
        
        let yOffset = CGFloat(row) * cellHeight
        calendarCollectionView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = Constants.monday
        
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let numberOfDays = range.count
        
        // Считаем dayOffset для 1-го числа текущего месяца
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        let dayOffset = (
            weekdayOfFirstDay - calendar.firstWeekday + Constants.numberOfDaysInWeek
        ) % Constants.numberOfDaysInWeek
        
        let totalCells = numberOfDays + dayOffset
        return Int(ceil(Double(totalCells) / Constants.daysInWeek)) * Constants.numberOfDaysInWeek
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell",
                                                      for: indexPath) as! CalendarDayCell
        
        var calendar = Calendar.current
        calendar.firstWeekday = Constants.monday
        
        // Первый день текущего месяца
        let firstDayOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: currentDate)
        )!
        
        // Считаем смещение
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        let dayOffset = (
            weekdayOfFirstDay - calendar.firstWeekday + Constants.numberOfDaysInWeek
        ) % Constants.numberOfDaysInWeek
        
        // Кол-во дней в текущем, предыдущем и следующем месяце
        let daysInCurrentMonth = calendar.range(of: .day, in: .month, for: currentDate)!.count
        
        let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonthDate)!.count
        
        let index = indexPath.item - dayOffset
        
        let day: Int
        let cellDate: Date
        let isCurrentMonth: Bool
        
        if index < 0 {
            // Предыдущий месяц
            day = daysInPreviousMonth + index + 1
            cellDate = calendar.date(bySetting: .day, value: day, of: previousMonthDate)!
            isCurrentMonth = false
            
        } else if index >= 0 && index < daysInCurrentMonth {
            // Текущий месяц
            day = index + 1
            cellDate = calendar.date(bySetting: .day, value: day, of: currentDate)!
            isCurrentMonth = true
            
        } else {
            // Следующий месяц
            day = index - daysInCurrentMonth + 1
            cellDate = calendar.date(bySetting: .day, value: day, of: nextMonthDate)!
            isCurrentMonth = false
        }
        
        let isToday = calendar.isDateInToday(cellDate)
        let isSelected = calendar.isDate(cellDate, inSameDayAs: selectedDate ?? Date())
        let textColor = isCurrentMonth ? UIColor.black : UIColor.color700
        
        cell.cellDate = cellDate
        cell.configure(with: day,
                       isCurrentMonth: isCurrentMonth,
                       isToday: isToday,
                       isSelected: isSelected,
                       textColor: textColor)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width
        let cellWidth = availableWidth / Constants.daysInWeek
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

// MARK: - UICollectionViewDelegate

extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarDayCell,
              let date = cell.cellDate else { return }
        
        // Если дата не принадлежит текущему месяцу – переходим на тот месяц, где находится эта дата
        if !Calendar.current.isDate(date, equalTo: currentDate, toGranularity: .month) {
            if let normalizedDate = Calendar.current.date(
                from: Calendar.current.dateComponents([.year, .month], from: date)
            ) {
                currentDate = normalizedDate
                updateTitle()
                collectionView.reloadData()
            }
        }
        
        // Устанавливаем выбранную дату
        selectedDate = date
        collectionView.reloadData()
        
        // Если календарь свёрнут, подскроллим неделю
        if isCalendarCollapsed {
            scrollToWeek(containing: date)
        }
        
        // Обновим расписание
        scheduleViewController.loadTasks(for: date)
    }
}
