//
//  CalendarViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 03.02.2025.
//

import UIKit

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Константы
    
    private enum Constants {
        static let titleFontSize: CGFloat = 27.0
        static let titleTopOffset: CGFloat = 20.0
        static let titleWidth: CGFloat = 245.0
        static let titleHeight: CGFloat = 30.0
        static let collectionViewLeftOffset: CGFloat = 20.0
        static let monthButtonRightOffset: CGFloat = 10.0
        
        // Константы для дней недели
        static let daysOfWeekStackViewTopOffset: CGFloat = 20.0
        static let daysOfWeekStackViewLeftOffset: CGFloat = 10.0
        static let daysOfWeekStackViewRightOffset: CGFloat = 10.0
        
        // Константы для календаря
        static let calendarCollectionViewTopOffset: CGFloat = 10.0
        static let calendarCollectionViewLeftOffset: CGFloat = 10.0
        static let calendarCollectionViewRightOffset: CGFloat = 10.0
        static let calendarCollectionViewBottomOffset: CGFloat = -20.0
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Nunito-ExtraBold", size: Constants.titleFontSize)
        label.textColor = .color800
        label.textAlignment = .left
        return label
    }()
    
    private let datePickerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "DownArrowIcon"), for: .normal)
        return button
    }()
    
    private let prevMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "LeftArrowIcon"), for: .normal)
        return button
    }()
    
    private let nextMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "RightArrowIcon"), for: .normal)
        return button
    }()
    
    private let daysOfWeekStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private var currentDate = Date()
    private var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Устанавливаем текущий день
        let calendar = Calendar.current
        currentDate = calendar.startOfDay(for: Date())
        selectedDate = currentDate
        
        setupUI()
        updateTitle()
    }

    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Title and navigation buttons
        view.addSubview(titleLabel)
        view.addSubview(datePickerButton)
        view.addSubview(prevMonthButton)
        view.addSubview(nextMonthButton)
        
        // Настройка заголовка
        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor, Constants.titleTopOffset)
        titleLabel.pinLeft(to: view, Constants.collectionViewLeftOffset)
        titleLabel.setHeight(mode: .equal, Constants.titleHeight)
        
        // Закрепляем стрелку выбора даты у края заголовка
        datePickerButton.pinCenterY(to: titleLabel.centerYAnchor)
        datePickerButton.pinLeft(to: titleLabel.trailingAnchor, 10)
        
        // Настройка кнопок переключения месяцев
        prevMonthButton.pinCenterY(to: titleLabel.centerYAnchor)
        prevMonthButton.pinRight(to: nextMonthButton.leadingAnchor, Constants.monthButtonRightOffset)
        
        nextMonthButton.pinCenterY(to: titleLabel.centerYAnchor)
        nextMonthButton.pinRight(to: view.trailingAnchor, Constants.monthButtonRightOffset)
        
        // Добавляем действия для кнопок
        datePickerButton.addTarget(self, action: #selector(showDatePicker), for: .touchUpInside)
        prevMonthButton.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        nextMonthButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        
        // Дни недели
        let daysOfWeek = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"]
        for day in daysOfWeek {
            let label = UILabel()
            label.text = day
            label.font = UIFont(name: "NunitoSans-Regular", size: 17)
            label.textColor = .color800
            label.textAlignment = .center
            daysOfWeekStackView.addArrangedSubview(label)
        }
        
        // Настройка дней недели
        view.addSubview(daysOfWeekStackView)
        daysOfWeekStackView.pinTop(to: titleLabel.bottomAnchor, Constants.daysOfWeekStackViewTopOffset)
        daysOfWeekStackView.pinLeft(to: view.leadingAnchor, Constants.daysOfWeekStackViewLeftOffset)
        daysOfWeekStackView.pinRight(to: view.trailingAnchor, Constants.daysOfWeekStackViewRightOffset)

        // Настройка календаря
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        view.addSubview(calendarCollectionView)
        calendarCollectionView.pinTop(to: daysOfWeekStackView.bottomAnchor, Constants.calendarCollectionViewTopOffset)
        calendarCollectionView.pinLeft(to: view.leadingAnchor, Constants.calendarCollectionViewLeftOffset)
        calendarCollectionView.pinRight(to: view.trailingAnchor, Constants.calendarCollectionViewRightOffset)
        calendarCollectionView.pinBottom(to: view.bottomAnchor, Constants.calendarCollectionViewBottomOffset)
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
        let monthIndex = Int(monthFormatter.string(from: currentDate))! - 1
        
        // Получаем название месяца из массива
        let monthString = monthNames[monthIndex]
        
        // Объединяем месяц и год с заглавной буквы
        titleLabel.text = "\(monthString) \(yearString)"
    }
    
    @objc private func showDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ru_RU")
        
        let alert = UIAlertController(title: "Выберите дату", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        
        alert.view.addSubview(datePicker)
        
        datePicker.pinTop(to: alert.view.topAnchor, 40)
        datePicker.pinLeft(to: alert.view.leadingAnchor, 20)
        datePicker.pinRight(to: alert.view.leadingAnchor, 20)
        datePicker.setHeight(mode: .equal, 160)
        
        let selectAction = UIAlertAction(title: "Выбрать", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentDate = datePicker.date
            self.selectedDate = datePicker.date // Устанавливаем выбранную дату
            self.updateTitle()
            self.calendarCollectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(selectAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func prevMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        updateTitle()
        calendarCollectionView.reloadData()
    }
    
    @objc private func nextMonth() {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        updateTitle()
        calendarCollectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let calendar = Calendar.current
        // Получаем количество дней в текущем месяце
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let numberOfDays = range.count
        
        // Получаем первый день месяца
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        
        // Получаем день недели для первого дня месяца
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        
        // Вычисляем смещение для первого дня месяца
        let dayOffset = (weekdayOfFirstDay - calendar.firstWeekday + 7) % 7
        
        // Вычисляем общее количество ячеек: дни месяца + смещение
        let totalCells = numberOfDays + dayOffset
        
        // Округляем до ближайшего кратного 7 (количество дней в неделе)
        let numberOfWeeks = (totalCells + 6) / 7
        
        // Возвращаем количество ячеек: недели * 7
        return numberOfWeeks * 7
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
        
        let calendar = Calendar.current
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        let dayOffset = (weekdayOfFirstDay - calendar.firstWeekday + 7) % 7
        
        let daysInCurrentMonth = calendar.range(of: .day, in: .month, for: currentDate)!.count
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)!.count

        var day: Int
        var cellDate: Date
        var isCurrentMonth = true
        
        if indexPath.item < dayOffset {
            // Дни из предыдущего месяца
            day = daysInPreviousMonth - (dayOffset - indexPath.item - 1)
            cellDate = calendar.date(bySetting: .day, value: day, of: previousMonth)!
            isCurrentMonth = false
        } else if indexPath.item - dayOffset < daysInCurrentMonth {
            // Дни текущего месяца
            day = indexPath.item - dayOffset + 1
            cellDate = calendar.date(bySetting: .day, value: day, of: currentDate)!
        } else {
            // Дни следующего месяца
            day = indexPath.item - dayOffset - daysInCurrentMonth + 1
            cellDate = calendar.date(bySetting: .day, value: day, of: nextMonth)!
            isCurrentMonth = false
        }
        
        let isToday = calendar.isDateInToday(cellDate)
        let isSelected = calendar.isDate(cellDate, inSameDayAs: selectedDate ?? Date())

        let textColor = isCurrentMonth ? UIColor.black : UIColor.color600
        
        cell.configure(
            with: day,
            isCurrentMonth: isCurrentMonth,
            isToday: isToday,
            isSelected: isSelected,
            textColor: textColor
        )
        
        return cell
    }

    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let calendar = Calendar.current
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let weekdayOfFirstDay = calendar.component(.weekday, from: firstDayOfMonth)
        let dayOffset = (weekdayOfFirstDay - calendar.firstWeekday + 7) % 7
        
        let day = indexPath.item - dayOffset + 1
        let daysInCurrentMonth = calendar.range(of: .day, in: .month, for: currentDate)!.count
        let isCurrentMonth = indexPath.item >= dayOffset && day <= daysInCurrentMonth
        
        if isCurrentMonth {
            // Если день принадлежит текущему месяцу, обновляем selectedDate
            selectedDate = calendar.date(bySetting: .day, value: day, of: currentDate)
        } else {
            // Определяем, к какому месяцу принадлежит выбранный день
            if day < 1 {
                // Переход к предыдущему месяцу
                currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
                let previousMonthDays = calendar.range(of: .day, in: .month, for: currentDate)!.count
                selectedDate = calendar.date(bySetting: .day, value: previousMonthDays + day, of: currentDate)
            } else {
                // Переход к следующему месяцу
                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
                selectedDate = calendar.date(bySetting: .day, value: day - daysInCurrentMonth, of: currentDate)
            }
        }
        
        // Обновляем заголовок и перерисовываем коллекцию
        updateTitle()
        calendarCollectionView.reloadData()
    }
}

class CalendarDayCell: UICollectionViewCell {
    
    // MARK: - Константы
    
    private enum Constants {
        static let dayLabelFontSize: CGFloat = 17.0
        static let todayBorderWidth: CGFloat = 1.0
        static let cornerRadius: CGFloat = 15.0
        static let todayTextColor: UIColor = .color500
    }
    
    // MARK: - UI Элементы
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NunitoSans-Regular", size: Constants.dayLabelFontSize)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Инициализаторы
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dayLabel)
        dayLabel.pinCenter(to: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Конфигурация
    func configure(with day: Int, isCurrentMonth: Bool, isToday: Bool, isSelected: Bool, textColor: UIColor) {
        dayLabel.text = day == 0 ? "" : "\(day)"
        dayLabel.textColor = textColor
        
        // Сбрасываем стили для всех ячеек
        contentView.backgroundColor = .white
        contentView.layer.borderColor = nil
        contentView.layer.borderWidth = 0
        contentView.layer.cornerRadius = 0
        
        if isToday {
            // Устанавливаем цвет текста для сегодняшней даты
            dayLabel.textColor = .color500
            
            // Добавляем обводку для сегодняшней даты
            contentView.layer.borderColor = UIColor.color500.cgColor
            contentView.layer.borderWidth = Constants.todayBorderWidth
            contentView.layer.cornerRadius = Constants.cornerRadius
        }
        
        if isSelected {
            // Стили для выбранной даты
            contentView.backgroundColor = .color500
            contentView.layer.cornerRadius = Constants.cornerRadius
            dayLabel.textColor = .white
        }
    }
}
