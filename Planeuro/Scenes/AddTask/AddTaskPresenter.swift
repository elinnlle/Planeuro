//
//  AddTaskPresenter.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.03.2025.
//
//

import Foundation

protocol AddTaskPresenterProtocol {
    func viewDidLoad()
    func didTapSendButton(with text: String)
    func didTapYesButton()
    func didTapNoButton()
}

enum AddTaskState {
    case initialInput               // ждём первое описание
    case missingFields              // уточняем обязательные поля
    case waitingForComplexityAnswer // ждём ответа (да/нет) по сложной задаче
    case awaitingSubtasksSave       // открыт экран подзадач
    case final                      // закончено
}

final class AddTaskPresenter: AddTaskPresenterProtocol {
    weak var view: AddTaskView?
    var interactor: AddTaskInteractorProtocol

    private let gptService   = GPTService()
    private let tasksService = TasksService()

    private var currentState: AddTaskState = .initialInput
    private var currentTaskJSON: String    = ""
    private var currentSubtasksJSON: String = ""

    private var missingMandatory: [String] = []
    private var missingOptional:  [String] = []

    init(view: AddTaskView, interactor: AddTaskInteractorProtocol) {
        self.view       = view
        self.interactor = interactor
    }

    func viewDidLoad() {
        view?.hideYesNoButtons()
        interactor.addInitialMessage()
    }

    func didTapSendButton(with text: String) {
        view?.hideYesNoButtons()
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "Введите сообщение..." else { return }
        interactor.addMessage(text: trimmed, isUser: true)

        switch currentState {
        case .initialInput:
            view?.showLoading()
            gptService.generateTaskJSON(taskDescription: trimmed) { [weak self] result in
                DispatchQueue.main.async {
                    self?.view?.hideLoading()
                    self?.handleInitialResponse(result)
                }
            }

        case .missingFields:
            view?.showLoading()
            gptService.updateTaskJSON(existingJSON: currentTaskJSON,
                                      clarifications: trimmed) { [weak self] result in
                DispatchQueue.main.async {
                    self?.view?.hideLoading()
                    self?.handleUpdateResponse(result)
                }
            }

        case .waitingForComplexityAnswer:
            let lower = trimmed.lowercased()
            if ["да", "yes", "ага", "конечно"].contains(where: lower.contains) {
                generateSubtasks()
            } else {
                saveFinalTaskAndNotify()
            }

        case .awaitingSubtasksSave:
            interactor.addMessage(
                text: "Сначала сохраните или отмените список подзадач.",
                isUser: false
            )

        case .final:
            interactor.addMessage(
                text: "Задача уже сохранена. Чтобы создать новую — начните заново.",
                isUser: false
            )
        }
    }

    func didTapYesButton() {
        currentState = .waitingForComplexityAnswer
        interactor.addMessage(text: "Да", isUser: true)
        generateSubtasks()
    }

    func didTapNoButton() {
        currentState = .waitingForComplexityAnswer
        interactor.addMessage(text: "Нет", isUser: true)
        saveFinalTaskAndNotify()
    }
}

// MARK: — Обработка ответов GPT

private extension AddTaskPresenter {

    func handleInitialResponse(_ result: Result<String, Error>) {
        switch result {
        case .failure(let error):
            interactor.addMessage(text: "Ошибка: \(error.localizedDescription)", isUser: false)

        case .success(let jsonString):
            // JSON больше не выводим в чат, только в консоль
            print("GPT Generated Task JSON:\n\(jsonString)\n")

            currentTaskJSON = jsonString
            missingMandatory = extractFields(from: jsonString, marker: "MISSING_FIELD")
            missingOptional  = extractFields(from: jsonString, marker: "empty")

            if !missingMandatory.isEmpty {
                currentState = .missingFields
                let prompt = promptForMissing(mandatory: missingMandatory,
                                              optional: missingOptional)
                interactor.addMessage(text: prompt, isUser: false)
            } else {
                currentTaskJSON = fillOptionalFields(in: jsonString)
                askIfNeedSplitIfComplex()
            }
        }
    }

    func handleUpdateResponse(_ result: Result<String, Error>) {
        switch result {
        case .failure(let error):
            interactor.addMessage(text: "Ошибка: \(error.localizedDescription)", isUser: false)

        case .success(let updatedJSON):
            // Обновлённый JSON — только в консоль
            print("GPT Updated Task JSON:\n\(updatedJSON)\n")

            currentTaskJSON = updatedJSON
            missingMandatory = extractFields(from: updatedJSON, marker: "MISSING_FIELD")
            missingOptional  = extractFields(from: updatedJSON, marker: "empty")

            if !missingMandatory.isEmpty {
                let prompt = promptForMissing(mandatory: missingMandatory,
                                              optional: missingOptional)
                interactor.addMessage(text: prompt, isUser: false)
            } else {
                currentTaskJSON = fillOptionalFields(in: updatedJSON)
                askIfNeedSplitIfComplex()
            }
        }
    }

    func extractFields(from json: String, marker: String) -> [String] {
        guard
            let data = json.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return [] }

        return dict.compactMap { key, value in
            if let s = value as? String, s.contains(marker) {
                return key
            }
            return nil
        }
    }

    func promptForMissing(mandatory: [String], optional: [String]) -> String {
        var result = "Обнаружены недостающие поля!\n"
        if !mandatory.isEmpty {
            result += "\nОбязательные:\n• " + mandatory.joined(separator: "\n• ")
        }
        if !optional.isEmpty {
            result += "\n\nНеобязательные (по желанию):\n• " + optional.joined(separator: "\n• ")
        }
        result += "\n\nПожалуйста, заполните обязательные поля для продолжения."
        return result
    }


    func fillOptionalFields(in jsonString: String) -> String {
        guard
            let data = jsonString.data(using: .utf8),
            var dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return jsonString }

        if let place = dict["место"] as? String, place.contains("empty") {
            dict["место"] = ""
        } else if dict["место"] == nil {
            dict["место"] = ""
        }
        if let travel = dict["время на дорогу"] as? String, travel.contains("empty") {
            dict["время на дорогу"] = 0
        } else if dict["время на дорогу"] == nil {
            dict["время на дорогу"] = 0
        }

        if let newData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]),
           let newJSON = String(data: newData, encoding: .utf8) {
            return newJSON
        }
        return jsonString
    }

    func askIfNeedSplitIfComplex() {
        guard
            let data = currentTaskJSON.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let complexity = dict["сложность"] as? String
        else {
            saveFinalTaskAndNotify()
            return
        }

        if complexity.lowercased() == "сложная" {
            view?.showYesNoButtons()
            interactor.addMessage(
                text: "Задача сложная — разбить на подзадачи? (да/нет)",
                isUser: false
            )
            currentState = .waitingForComplexityAnswer
        } else {
            saveFinalTaskAndNotify()
        }
    }

    func saveFinalTaskAndNotify() {
        view?.showYesNoButtons()
        guard
            let data = currentTaskJSON.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            interactor.addMessage(text: "Ошибка: не удалось сохранить задачу.", isUser: false)
            return
        }

        let rawTitle = dict["название задачи"] as? String ?? "Без названия"
        let startStr = dict["начало задачи"] as? String ?? ""
        let endStr   = dict["конец задачи"] as? String ?? ""

        if [rawTitle, startStr, endStr].contains(where: { $0.contains("MISSING_FIELD") }) {
            interactor.addMessage(
                text: "Невозможно сохранить: остались незаполненные обязательные поля.",
                isUser: false
            )
            return
        }

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm"
        guard
            let startDate = fmt.date(from: startStr),
            let endDate   = fmt.date(from: endStr)
        else {
            interactor.addMessage(
                text: "Ошибка: неверный формат дат.",
                isUser: false
            )
            return
        }

        let address  = dict["место"] as? String ?? ""
        let travel   = dict["время на дорогу"] as? Int    ?? 0
        let catTitle = dict["название категории"] as? String ?? ""
        let catColor = dict["цвет категории"] as? String    ?? ""

        tasksService.addNewTask(
            title: rawTitle,
            startDate: startDate,
            endDate: endDate,
            address: address,
            timeTravel: travel,
            categoryColor: catColor,
            categoryTitle: catTitle,
            status: .active,
            taskType: .userDefined
        )

        let newTask = Tasks(
            title: rawTitle,
            startDate: startDate,
            endDate: endDate,
            address: address,
            timeTravel: travel,
            categoryColorName: catColor,
            categoryTitle: catTitle,
            status: .active,
            type: .userDefined
        )
        view?.openEditTask(newTask)
        interactor.addMessage(text: "Задача «\(rawTitle)» успешно сохранена.", isUser: false)
        // Сброс к новому вводу
        currentTaskJSON     = ""
        currentSubtasksJSON = ""
        missingMandatory    = []
        missingOptional     = []
        currentState        = .initialInput
        interactor.addRepeatMessage()
    }

    func generateSubtasks() {
        view?.hideYesNoButtons()
        view?.showLoading()
        gptService.generateSplittingVariants(taskJSON: currentTaskJSON) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoading()
                switch result {
                case .failure(let error):
                    self?.interactor.addMessage(
                        text: "Ошибка при генерации подзадач: \(error.localizedDescription)",
                        isUser: false
                    )
                case .success(let variantsJSON):
                    guard let self = self else { return }
                    // Вывод в консоль, не в чат
                    print("GPT Generated Subtasks JSON:\n\(variantsJSON)\n")
                    self.currentSubtasksJSON = variantsJSON
                    self.view?.openSubtasksView(
                        with: variantsJSON,
                        onAccept: { [weak self] acceptedJSON in
                            self?.handleSubtasksSaved(acceptedJSON)
                        }
                    )
                    self.currentState = .awaitingSubtasksSave
                }
            }
        }
    }

    func handleSubtasksSaved(_ json: String) {
        saveSubtasksToDB(from: json)
        interactor.addMessage(text: "Подзадачи успешно сохранены.", isUser: false)
        // Сброс к новому вводу
        currentTaskJSON     = ""
        currentSubtasksJSON = ""
        missingMandatory    = []
        missingOptional     = []
        currentState        = .initialInput
        interactor.addRepeatMessage()
    }

    func saveSubtasksToDB(from json: String) {
        guard let data = json.data(using: .utf8) else { return }

        struct SubtaskDTO: Codable {
            let title: String
            let start: String
            let end: String
            let location: String
            let travelTime: Int
            let categoryColor: String
            let categoryName: String
            let status: String
            let taskType: String
            let difficulty: String

            enum CodingKeys: String, CodingKey {
                case title           = "название подзадачи"
                case start           = "начало подзадачи"
                case end             = "конец подзадачи"
                case location        = "место"
                case travelTime      = "время на дорогу"
                case categoryColor   = "цвет категории"
                case categoryName    = "название категории"
                case status          = "статус"
                case taskType        = "тип задачи"
                case difficulty      = "сложность"
            }
        }

        let decoder = JSONDecoder()
        guard let list = try? decoder.decode([SubtaskDTO].self, from: data) else { return }

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm"

        for dto in list {
            guard
                let s = fmt.date(from: dto.start),
                let e = fmt.date(from: dto.end)
            else { continue }

            tasksService.addNewTask(
                title: dto.title,
                startDate: s,
                endDate: e,
                address: dto.location,
                timeTravel: dto.travelTime,
                categoryColor: dto.categoryColor,
                categoryTitle: dto.categoryName,
                status: .active,
                taskType: .userDefined
            )
        }
    }
}

// MARK: — AddTaskInteractorOutput

extension AddTaskPresenter: AddTaskInteractorOutput {
    func didAddMessage(_ message: Message) {
        view?.displayNewMessage(message)
    }
}
