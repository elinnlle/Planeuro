//
//  SubtasksViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 06.04.2025.
//

import UIKit

final class SubtasksViewController: UIViewController {

    // MARK: - Constants
    private enum Constants {
        static let screenTitle = "Разбиение задачи"
        static let headerTitle = "Список задач"
        static let headerFontName = "Nunito-ExtraBold"
        static let headerFontSize: CGFloat = 27
        static let hintText = "Нажмите на задачу, чтобы изменить её\nи смахните влево, чтобы удалить"
        static let hintFontName = "Nunito-Regular"
        static let hintFontSize: CGFloat = 17
        static let titleTopPadding: CGFloat = 20
        static let hintTopPadding: CGFloat = 8
        static let tableViewTopPadding: CGFloat = 14
        static let taskCellIdentifier = "TaskCell"
        static let taskCellHeight: CGFloat = 106
        static let plusIconName = "PlusSubtasksIcon"
        static let acceptIconName = "AcceptIcon"
        static let gradientImageName = "Gradient"
        static let deleteIconName = "DeleteIcon"
        static let dateFormat = "yyyy-MM-dd HH:mm"
    }

    // MARK: - Callback
    var onAccept: ((String) -> Void)?

    // MARK: - UI & Data
    private let json: String
    private var subtasks: [Subtask] = []
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let titleLabel = UILabel()
    private let hintLabel  = UILabel()
    public private(set) var bottomBarManager: BottomBarManager!

    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = Constants.dateFormat
        df.locale = .current
        return df
    }()

    // MARK: - Init
    init(json: String) {
        self.json = json
        super.init(nibName: nil, bundle: nil)
        title = Constants.screenTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupHeader()
        setupTableView()
        setupBottomBar()
        parseJSON()
    }

    // MARK: - Setup Header
    private func setupHeader() {
        titleLabel.text = Constants.headerTitle
        titleLabel.font = UIFont(name: Constants.headerFontName, size: Constants.headerFontSize)
        titleLabel.textColor = .color800
        titleLabel.textAlignment = .center

        hintLabel.text = Constants.hintText
        hintLabel.font = UIFont(name: Constants.hintFontName, size: Constants.hintFontSize)
        hintLabel.textColor = .black
        hintLabel.textAlignment = .center
        hintLabel.numberOfLines = 2

        [titleLabel, hintLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.titleTopPadding),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            hintLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.hintTopPadding),
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Setup TableView
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: Constants.taskCellIdentifier)
        tableView.rowHeight = Constants.taskCellHeight
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: Constants.tableViewTopPadding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Setup BottomBar
    private func setupBottomBar() {
        let cfg = BottomBarConfiguration(
            icons: [Constants.plusIconName, Constants.acceptIconName],
            gradientImage: Constants.gradientImageName
        )
        bottomBarManager = BottomBarManager(view: view, configuration: cfg)
        bottomBarManager.delegate = self
    }

    // MARK: - JSON Parsing
    private func parseJSON() {
        guard let data = json.data(using: .utf8) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        subtasks = (try? decoder.decode([Subtask].self, from: data)) ?? []
    }

    private func jsonString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        guard let data = try? encoder.encode(subtasks) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }
}

// MARK: - BottomBarManagerDelegate
extension SubtasksViewController: BottomBarManagerDelegate {
    func bottomBarManagerDidTapBack(_ manager: BottomBarManager) {}
    func bottomBarManagerDidTapTrash(_ manager: BottomBarManager) {}

    func bottomBarManagerNewSubtask(_ manager: BottomBarManager) {
        let newTask = Tasks()
        let editor = EditTaskViewController(task: newTask, shouldSaveToDB: false, indexInParent: nil)
        editor.delegate = self
        navigationController?.pushViewController(editor, animated: true)
    }

    func bottomBarManagerAcceptSubtasks(_ manager: BottomBarManager) {
        onAccept?(jsonString())
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate
extension SubtasksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ t: UITableView, numberOfRowsInSection s: Int) -> Int {
        subtasks.count
    }

    func tableView(_ t: UITableView, cellForRowAt i: IndexPath) -> UITableViewCell {
        let st = subtasks[i.row]
        let cell = t.dequeueReusableCell(withIdentifier: Constants.taskCellIdentifier, for: i) as! TaskCell

        let task = st.toTask()
        cell.configure(with: task)
        cell.showsStatus = false
        return cell
    }

    func tableView(_ t: UITableView, didSelectRowAt indexPath: IndexPath) {
        t.deselectRow(at: indexPath, animated: true)
        let st = subtasks[indexPath.row]

        let editor = EditTaskViewController(
            task: st.toTask(),
            shouldSaveToDB: false,
            indexInParent: indexPath.row
        )
        editor.delegate = self
        navigationController?.pushViewController(editor, animated: true)
    }

    func tableView(_ t: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: nil) { _, _, done in
            self.subtasks.remove(at: indexPath.row)
            t.deleteRows(at: [indexPath], with: .automatic)
            done(true)
        }
        delete.image = UIImage(named: Constants.deleteIconName)
        delete.backgroundColor = .white
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - TaskEditorDelegate
extension SubtasksViewController: TaskEditorDelegate {
    func taskEditor(_ editor: EditTaskViewController, didFinishEditing task: Tasks, at index: Int?) {
        let st = Subtask.from(task: task)
        if let i = index {
            subtasks[i] = st
        } else {
            subtasks.append(st)
        }
        tableView.reloadData()
    }

    func taskEditorDidDelete(_ editor: EditTaskViewController, at index: Int) {
        subtasks.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

// MARK: - Протокол делегата для редактора
protocol TaskEditorDelegate: AnyObject {
    func taskEditor(_ editor: EditTaskViewController, didFinishEditing task: Tasks, at index: Int?)
    func taskEditorDidDelete(_ editor: EditTaskViewController, at index: Int)
}

// MARK: - Утилиты
private extension Subtask {
    func toTask() -> Tasks {
        let status: TaskStatus = {
            switch self.status.lowercased() {
            case "completed": return .completed
            case "overdue":   return .overdue
            default:          return .active
            }
        }()
        let type: TaskType = (self.taskType.lowercased() == "airecommendation" ? .aiRecommendation : .userDefined)
        
        return Tasks(
            title: self.title,
            startDate: self.start,
            endDate:   self.end,
            address:   self.location,
            timeTravel: self.travelTime,
            categoryColorName: self.categoryColor,
            categoryTitle:   self.categoryName,
            status:          status,
            type:            type,
            eventIdentifier: nil
        )
    }

    static func from(task: Tasks) -> Subtask {
        let statusString: String = {
            switch task.status {
            case .completed: return "completed"
            case .overdue:   return "overdue"
            default:         return "active"
            }
        }()
        let taskTypeString = (task.type == .aiRecommendation ? "aiRecommendation" : "userDefined")

        return Subtask(
            title:         task.title,
            start:         task.startDate,
            end:           task.endDate,
            location:      task.address,
            travelTime:    task.timeTravel,
            categoryColor: task.categoryColorName,
            categoryName:  task.categoryTitle,
            status:        statusString,
            taskType:      taskTypeString,
            difficulty:    "простая"
        )
    }
}

// MARK: - Пустой Task для кнопки «плюс»
extension Tasks {
    init() {
        self.init(
            title: "Без названия",
            startDate: Date(),
            endDate: Date(),
            address: "",
            timeTravel: 0,
            categoryColorName: "",
            categoryTitle: "",
            status: .active,
            type: .userDefined,
            eventIdentifier: nil
        )
    }
}
