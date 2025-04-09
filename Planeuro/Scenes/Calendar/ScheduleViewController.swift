//
//  ScheduleViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 08.04.2025.
//

import UIKit

class ScheduleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: — Константы
    private struct Constants {
        static let overlayAlpha: CGFloat = 0.3
        static let minimumLineSpacing: CGFloat = 10
        static let minimumInteritemSpacing: CGFloat = 10
        static let longPressDuration: TimeInterval = 0.3
        static let cellHeight: CGFloat = 68
        }

    // MARK: — Свойства
    
    private let taskPresenter = TaskPresenter()
    private var tasks: [Tasks] = []
    private var displayDate: Date = Date()
    private var displayItems: [DisplayItem] = []
    private(set) var bottomBarManager: BottomBarManager!

    // MARK: — Загрузка и скрытие индикатора
    
    private var loadingOverlay: UIView?

    private func showLoading() {
        // Создаём overlay
        let overlay = UIView()
        overlay.backgroundColor = UIColor(white: 0, alpha: Constants.overlayAlpha)
        overlay.translatesAutoresizingMaskIntoConstraints = false

        // Создаём спиннер
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()

        overlay.addSubview(spinner)

        // Добавляем overlay непосредственно в окно приложения
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(overlay)

            NSLayoutConstraint.activate([
                // растягиваем по всему окну
                overlay.topAnchor.constraint(equalTo: window.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                overlay.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                // и центрируем спиннер
                spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            ])

            loadingOverlay = overlay
        }
    }

    private func hideLoading() {
        loadingOverlay?.removeFromSuperview()
        loadingOverlay = nil
    }

    // MARK: — Коллекция задач

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing      = Constants.minimumLineSpacing
        layout.minimumInteritemSpacing = Constants.minimumInteritemSpacing
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate   = self
        cv.register(ScheduleTaskCell.self, forCellWithReuseIdentifier: "ScheduleTaskCell")
        cv.backgroundColor = .white
        return cv
    }()

    // MARK: — Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.pinTop(to: view.topAnchor)
        collectionView.pinBottom(to: view.bottomAnchor)
        collectionView.pinLeft(to: view.leadingAnchor)
        collectionView.pinRight(to: view.trailingAnchor)

        let customConfig = BottomBarConfiguration(
            icons: ["HomeIconAdd", "CalendarIcon", "SettingsIconAdd"],
            gradientImage: "Gradient"
        )
        bottomBarManager = BottomBarManager(view: self.view, configuration: customConfig)

        taskPresenter.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadTasks),
            name: .init("TasksUpdated"),
            object: nil
        )
        loadTasks(for: displayDate)

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        longPress.minimumPressDuration = Constants.longPressDuration
        collectionView.addGestureRecognizer(longPress)
    }
    
    // MARK: — Загрузка и обновление задач

    @objc private func reloadTasks() {
        let dateToLoad = (parent as? CalendarViewController)?.selectedDate ?? Date()
        loadTasks(for: dateToLoad)
    }

    func loadTasks(for date: Date) {
        displayDate = date
        taskPresenter.loadTasks(for: date)

        let cal         = Calendar.current
        let startOfDay  = cal.startOfDay(for: date)
        guard let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        CalendarManager.shared.fetchEvents(startDate: startOfDay, endDate: endOfDay) { [weak self] events in
            guard let self = self else { return }
            let dbTasks = self.tasks
            let evTasks = events
                .filter { $0.startDate < endOfDay && $0.endDate >= startOfDay }
                .map { Tasks(from: $0) }
            let existingIDs = Set(dbTasks.compactMap { $0.eventIdentifier })
            let filtered = evTasks.filter {
                $0.eventIdentifier.map { !existingIDs.contains($0) } ?? true
            }
            self.tasks = (dbTasks + filtered).sorted { $0.startDate < $1.startDate }
            self.buildDisplayItems()
            self.collectionView.reloadData()
        }
    }
    
    // MARK: — Построение элементов отображения
    
    private func buildDisplayItems() {
        let cal        = Calendar.current
        let startOfDay = cal.startOfDay(for: displayDate)
        guard let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay) else {
            displayItems = []
            return
        }

        // 1) full-day задачи
        let fullDayTasks = tasks.filter { t in
            let isExactFullDay = cal.component(.hour, from: t.startDate) == 0 &&
                                 cal.component(.minute, from: t.startDate) == 0 &&
                                 cal.component(.hour, from: t.endDate)   == 23 &&
                                 cal.component(.minute, from: t.endDate) == 59

            let coversWhole = t.startDate <= startOfDay && t.endDate >= endOfDay

            let dayCount = cal.dateComponents([.day], from: t.startDate, to: t.endDate).day ?? 0
            let isMultiDay = dayCount >= 1

            return isExactFullDay || coversWhole || isMultiDay
        }

        // 2) обычные задачи
        let timedTasks = tasks
            .filter { t in !fullDayTasks.contains(t) }
            .sorted { $0.startDate < $1.startDate }

        // 3) собираем travel → task → реальный gap
        var scheduleItems: [DisplayItem] = []
        for i in 0..<timedTasks.count {
            let t = timedTasks[i]
            if t.timeTravel > 0 {
                let ts = cal.date(byAdding: .minute, value: -t.timeTravel, to: t.startDate)!
                scheduleItems.append(.travel(time: ts, duration: t.timeTravel))
            }
            scheduleItems.append(.task(time: t.startDate, task: t))
            if i < timedTasks.count - 1 {
                let nxt = timedTasks[i+1]
                if t.endDate < nxt.startDate {
                    scheduleItems.append(.gap(start: t.endDate, end: nxt.startDate))
                }
            }
        }
        // gap от конца последней задачи до сна (или до конца дня)
        if let last = timedTasks.last {
            var gapEnd = endOfDay
            if let sleep = UserDefaults.standard.object(forKey: "sleepTime") as? Date {
                var c = cal.dateComponents([.hour, .minute], from: sleep)
                c.year  = cal.component(.year,  from: displayDate)
                c.month = cal.component(.month, from: displayDate)
                c.day   = cal.component(.day,   from: displayDate)
                if let dt = cal.date(from: c) {
                    gapEnd = dt
                }
            }
            if last.endDate < gapEnd {
                scheduleItems.append(.gap(start: last.endDate, end: gapEnd))
            }
        }

        // 4) morning/night
        var greetingItems: [DisplayItem] = []
        let ds = UserDefaults.standard
        if let wake = ds.object(forKey: "wakeUpTime") as? Date {
            var c = cal.dateComponents([.hour, .minute], from: wake)
            c.year  = cal.component(.year,  from: displayDate)
            c.month = cal.component(.month, from: displayDate)
            c.day   = cal.component(.day,   from: displayDate)
            if let dt = cal.date(from: c) {
                greetingItems.append(.greetingMorning(time: dt, taskCount: tasks.count))
            }
        }
        if let sleep = ds.object(forKey: "sleepTime") as? Date {
            var c = cal.dateComponents([.hour, .minute], from: sleep)
            c.year  = cal.component(.year,  from: displayDate)
            c.month = cal.component(.month, from: displayDate)
            c.day   = cal.component(.day,   from: displayDate)
            if let dt = cal.date(from: c) {
                greetingItems.append(.greetingNight(time: dt))
            }
        }

        // 5) вставляем часовые метки — только если они не пересекутся ни с одной задачей, travel или real-gap
        let scheduleIntervals: [(start: Date, end: Date)] = scheduleItems.compactMap { item in
            switch item {
            case .travel(let t, let d):
                return (start: t, end: t.addingTimeInterval(TimeInterval(d * 60)))
            case .task(_, let task):
                return (start: task.startDate, end: task.endDate)
            case .gap(let s, let e):
                return (start: s, end: e)
            default:
                return nil
            }
        }

        var merged = scheduleItems + greetingItems

        func timeOf(_ it: DisplayItem) -> Date {
            switch it {
            case .travel(let t, _):          return t
            case .task(let t, _):            return t
            case .gap(let s, _):             return s
            case .greetingMorning(let t, _): return t
            case .greetingNight(let t):      return t
            case .fullDay:                   return startOfDay
            }
        }

        if let first = merged.map(timeOf).min(),
           let last  = merged.map(timeOf).max() {
            let startHour = cal.component(.hour, from: first)
            let endHour   = cal.component(.hour, from: last)

            for hr in startHour...endHour {
                var dc = cal.dateComponents([.year, .month, .day], from: displayDate)
                dc.hour   = hr
                dc.minute = 0
                dc.second = 0
                guard let boundary = cal.date(from: dc),
                      !merged.contains(where: { timeOf($0) == boundary })
                else { continue }

                let boundaryEnd = cal.date(byAdding: .hour, value: 1, to: boundary)!
                // пропускаем, если отрезок пересекается с любым из scheduleIntervals
                let intersects = scheduleIntervals.contains { interval in
                    interval.start < boundaryEnd && interval.end > boundary
                }
                if !intersects {
                    merged.append(.gap(start: boundary, end: boundaryEnd))
                }
            }
        }

        // 6) сортируем + добавляем full-day
        let sortedMerged = merged.sorted { timeOf($0) < timeOf($1) }
        var items = fullDayTasks.map { .fullDay(task: $0) } + sortedMerged

        // 7) фильтруем gap внутри travel
        let travelIntervals: [(Date,Date)] = scheduleItems.compactMap {
            if case .travel(let t, let d) = $0 {
                return (t, t.addingTimeInterval(TimeInterval(d * 60)))
            }
            return nil
        }
        items = items.filter {
            if case .gap(let s, _) = $0 {
                return !travelIntervals.contains { s >= $0 && s < $1 }
            }
            return true
        }

        // 8) слияние подряд идущих gap
        var mergedGaps: [DisplayItem] = []
        var gapRunStart: Date?
        var gapRunEnd:   Date?

        for it in items {
            if case .gap(let s, let e) = it {
                if gapRunStart == nil {
                    gapRunStart = s
                    gapRunEnd   = e
                } else {
                    gapRunEnd = max(gapRunEnd!, e)
                }
            } else {
                if let start = gapRunStart, let end = gapRunEnd {
                    mergedGaps.append(.gap(start: start, end: end))
                    gapRunStart = nil
                    gapRunEnd   = nil
                }
                mergedGaps.append(it)
            }
        }
        if let start = gapRunStart, let end = gapRunEnd {
            mergedGaps.append(.gap(start: start, end: end))
        }

        displayItems = mergedGaps
        if displayItems.isEmpty {
            displayItems = [.gap(start: startOfDay, end: endOfDay)]
        }
    }
    
    // MARK: — UICollectionViewDataSource

    func numberOfSections(in _: UICollectionView) -> Int { displayItems.count }
        func collectionView(_ _: UICollectionView, numberOfItemsInSection _: Int) -> Int { 1 }

        func collectionView(_ cv: UICollectionView,
                            cellForItemAt ip: IndexPath) -> UICollectionViewCell {
            let cell = cv.dequeueReusableCell(
                withReuseIdentifier: "ScheduleTaskCell",
                for: ip
            ) as! ScheduleTaskCell
            cell.configure(with: displayItems[ip.section], userColor: UIColor.color300)
            return cell
        }

        // MARK: UICollectionViewDelegate

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            switch displayItems[indexPath.section] {
            case .task(_, let task), .fullDay(let task):
                let editVC = EditTaskViewController(task: task)
                navigationController?.pushViewController(editVC, animated: true)
            default:
                break
            }
        }

        // MARK: UICollectionViewDelegateFlowLayout

        func collectionView(_ _: UICollectionView,
                            layout _: UICollectionViewLayout,
                            sizeForItemAt _: IndexPath) -> CGSize {
            CGSize(width: collectionView.bounds.width, height: Constants.cellHeight)
        }

        // MARK: Gesture Handler

        @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began else { return }
            let point = gesture.location(in: collectionView)
            guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        
            if case .gap(let start, let end) = displayItems[indexPath.section] {
                let enabled = UserDefaults.standard.bool(forKey: "recommendationsEnabled")
                guard enabled else {
                    return
                }
                recommendForGap(start: start, end: end)
            }
        }

        // MARK: Date Formatters

        private var isoDayFormatter: DateFormatter = {
            let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
        }()
        private var timeFormatter: DateFormatter = {
            let f = DateFormatter(); f.dateFormat = "HH:mm"; return f
        }()

        // MARK: — Recommendation

        private func recommendForGap(start: Date, end: Date) {
            let dayStr   = isoDayFormatter.string(from: start)
            let slotStart = timeFormatter.string(from: start)
            let slotEnd   = timeFormatter.string(from: end)

            let tasksPayload: [[String: Any]] = tasks.map { t in
                [
                    "title":      t.title,
                    "start":      timeFormatter.string(from: t.startDate),
                    "end":        timeFormatter.string(from: t.endDate),
                    "deadline":   isoDayFormatter.string(from: t.endDate),
                    "duration_h": Int(t.endDate.timeIntervalSince(t.startDate) / 3600)
                ]
            }

            let last7DaysHours: [Int] = getLast7DaysBusyHours()

            // показываем центральный лоадер
            showLoading()

            GPTService().recommendSlot(
                date: dayStr,
                slotStart: slotStart,
                slotEnd: slotEnd,
                tasks: tasksPayload,
                dailyHours: last7DaysHours
            ) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    // скрываем лоадер
                    self.hideLoading()

                    switch result {
                    case .failure(let err):
                        self.showError(err.localizedDescription)
                    case .success(let rec):
                        self.showRecommendation(rec, for: start, end: end)
                    }
                }
            }
        }

        private func getLast7DaysBusyHours() -> [Int] {
            let calendar = Calendar.current
            var result: [Int] = []

            for offset in 1...7 {
                guard let date = calendar.date(byAdding: .day, value: -offset, to: displayDate) else { continue }
                let startOfDay = calendar.startOfDay(for: date)
                guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { continue }

                let todays = tasks.filter { t in
                    t.startDate < endOfDay && t.endDate > startOfDay
                }

                let hours = todays.reduce(0) { sum, t in
                    let sliceStart = max(t.startDate, startOfDay)
                    let sliceEnd   = min(t.endDate,   endOfDay)
                    let h = calendar.dateComponents([.hour], from: sliceStart, to: sliceEnd).hour ?? 0
                    return sum + h
                }
                result.append(hours)
            }

            return result
        }

        private func showError(_ text: String) {
            let a = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)
            a.addAction(.init(title: "ОК", style: .cancel))
            present(a, animated: true)
        }
    
    /// Отображение рекомендации
    private func showRecommendation(_ rec: SlotRecommendation, for start: Date, end: Date) {
        let alert = UIAlertController(title: nil, message: rec.message, preferredStyle: .alert)

        // Форматтер для составления дат
        let fmtDateTime: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd HH:mm"
            return f
        }()
        let dayPrefix = isoDayFormatter.string(from: start)

        // Вспомогательная функция вставки одной задачи
        func insertTask(_ suggestion: SuggestedTask, at startDate: Date) {
            guard let startDT = fmtDateTime.date(from: "\(dayPrefix) \(timeFormatter.string(from: startDate))") else { return }
            let endDT = Calendar.current.date(byAdding: .hour, value: suggestion.duration_h, to: startDT)!
            TasksService().addNewTask(
                title: suggestion.title,
                startDate: startDT,
                endDate: endDT,
                address: "",
                timeTravel: 0,
                categoryColor: "",
                categoryTitle: "",
                status: .active,
                taskType: .aiRecommendation
            )
        }

        // 1) Если несколько рекомендаций — кнопки для каждой и кнопка "Вставить все"
        if rec.recommendation == "insert_task", !rec.suggested.isEmpty {
            // Отдельные кнопки
            for suggestion in rec.suggested {
                alert.addAction(.init(
                    title: "Вставить «\(suggestion.title)»",
                    style: .default,
                    handler: { _ in
                        insertTask(suggestion, at: start)
                        self.loadTasks(for: Calendar.current.startOfDay(for: self.displayDate))
                    }
                ))
            }
            // Кнопка "Вставить все"
            if rec.suggested.count > 1 {
                alert.addAction(.init(
                    title: "Вставить все",
                    style: .default,
                    handler: { _ in
                        var currentStart = start
                        for suggestion in rec.suggested {
                            insertTask(suggestion, at: currentStart)
                            if let newStart = Calendar.current.date(byAdding: .hour, value: suggestion.duration_h, to: currentStart) {
                                currentStart = newStart
                            }
                        }
                        self.loadTasks(for: Calendar.current.startOfDay(for: self.displayDate))
                    }
                ))
            }
        }

        // Всегда добавляем кнопку "Закрыть"
        alert.addAction(.init(title: "Закрыть", style: .cancel))

        present(alert, animated: true)
    }
}

extension ScheduleViewController: TaskPresenterDelegate {
    func updateTasks(_ tasks: [Tasks]) {
        self.tasks = tasks.sorted { $0.startDate < $1.startDate }
        buildDisplayItems()
        collectionView.reloadData()
    }
}

