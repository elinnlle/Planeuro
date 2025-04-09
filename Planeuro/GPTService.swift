//
//  GPTService.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.03.2025.
//

import Foundation

// MARK: – Constants

private enum APIConstants {
    static let apiKey = "security_key"
    static let baseURLString = "https://hubai.loe.gg/v1"
    static let modelName = "gpt-4o-mini"
    static let defaultMaxTokens = 1300
    static let defaultTemperature = 0.0
}

private enum TimeConstants {
    static let minutesPerHour = 60
    static let longTaskHourThreshold = 24
    static let daysWindow = 3
    static let weeksWindow = 7
}

/// Структура для сообщений в GPT‑чат
struct GPTChatMessage: Codable {
    let role: String  // "system" | "user" | "assistant"
    let content: String
}

/// Структура для тела запроса ChatCompletion
struct GPTChatRequest: Codable {
    let model: String
    let messages: [GPTChatMessage]
    let temperature: Double
    let max_tokens: Int
}

/// Вариант ответа GPT в choices
struct GPTChatChoice: Codable {
    let message: GPTChatMessage
}

/// Ответ ChatCompletion
struct GPTChatResponse: Codable {
    let choices: [GPTChatChoice]
}

/// Основной класс для взаимодействия с сервером GPT
final class GPTService {
    
    private let apiKey = APIConstants.apiKey
    private let baseURLString = APIConstants.baseURLString
    private let modelName = APIConstants.modelName
    
    // MARK: — Общая функция отправки (chat.completions)
    private func chatWithGPT(messages: [GPTChatMessage],
                             maxTokens: Int = APIConstants.defaultMaxTokens,
                             temperature: Double = APIConstants.defaultTemperature,
                             completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let url = URL(string: "\(baseURLString)/chat/completions") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }
        let requestBody = GPTChatRequest(
            model: modelName,
            messages: messages,
            temperature: temperature,
            max_tokens: maxTokens
        )
        guard let httpBody = try? JSONEncoder().encode(requestBody) else {
            completion(.failure(NSError(domain: "JSON encoding error", code: -1)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let err = error {
                completion(.failure(err)); return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "Empty data", code: -1))); return
            }
            do {
                let chatResp = try JSONDecoder().decode(GPTChatResponse.self, from: data)
                if let first = chatResp.choices.first {
                    let reply = first.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
                    completion(.success(reply))
                } else {
                    completion(.failure(NSError(domain: "No choices in response", code: -1)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: — 1. Генерация начального JSON задачи
    func generateTaskJSON(taskDescription: String,
                          completion: @escaping (Result<String, Error>) -> Void) {
        let now = Date()
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let today = fmt.string(from: now)
        
        let systemMessage = """
        Сегодня: \(today).
        Ты — ассистент для обработки пользовательских задач. На основе входного текста пользователя сгенерируй валидный JSON-объект, который будет использован для создания новой задачи в базе данных.
        Требования к структуре JSON:
        1. Обязательные поля. Если какое-либо из них отсутствует, в значение поля вставь строку "MISSING_FIELD: <название поля>":
           - "название задачи" (String) — выведи из текста краткое, осмысленное название.
           - "начало задачи" (дата и время начала в формате "yyyy-MM-dd HH:mm")
           - "конец задачи" (дата и время окончания в формате "yyyy-MM-dd HH:mm")
        2. Необязательные поля. Если какое-либо из них отсутствует, в значение поля вставь строку "empty":
           - "место" (String)
           - "время на дорогу" (Int, минуты)
        3. Фиксированные поля (всегда указываются вне зависимости от входных данных):
           - "цвет категории": ""
           - "название категории": ""
           - "статус": "active"
           - "тип задачи": "userDefined"
        4. Сложность задачи ("простая" или "сложная"):
           - Укажи "сложная", если задача включает несколько логически связанных действий, предварительную подготовку, высокую продолжительность или требует планирования.
           - Укажи "простая", если задача представляет собой одно действие, понятное и короткое, не требующее подготовки.
        Верни **только** валидный JSON без комментариев и пояснений.
        """
        
        let messages = [
            GPTChatMessage(role: "system", content: systemMessage),
            GPTChatMessage(role: "user", content: taskDescription)
        ]
        
        chatWithGPT(messages: messages, completion: completion)
    }
    
    // MARK: — 2. Обновление существующего JSON задачи
    func updateTaskJSON(existingJSON: String,
                        clarifications: String,
                        completion: @escaping (Result<String, Error>) -> Void) {
        let now = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        let systemMessage = """
        Сегодня: \(now).
        Ты ассистент для обработки задач. Тебе передан JSON текущей структурой задачи:
        ---------------------
        \(existingJSON)
        ---------------------
        Пользователь предоставил дополнительные уточнения: \(clarifications)
        Твоя задача — обновить JSON в соответствии с уточнениями.
        Правила обработки:
        1. Обязательные поля. Заполни все поля, где указано "MISSING_FIELD: <название поля>", используя информацию из уточнений:
           - "название задачи" (String) - осмысленное краткое название задачи
           - "начало задачи" (дата и время начала в формате "yyyy-MM-dd HH:mm")
           - "конец задачи" (дата и время окончания в формате "yyyy-MM-dd HH:mm")
        2. Необязательные поля. Если в уточнениях нет новых данных для места и времени на дорогу, замени "empty" на значения по умолчанию:
           - "место": ""
           - "время на дорогу": 0
        3. Фиксированные поля оставь без изменений:
           - "цвет категории": ""
           - "название категории": ""
           - "статус": "active"
           - "тип задачи": "userDefined"
        4. Сложность задачи: оставь без изменений.
        Верни **только** валидный JSON без комментариев и пояснений.
        """

        let messages = [ GPTChatMessage(role: "system", content: systemMessage) ]
        chatWithGPT(messages: messages, completion: completion)
    }
    
    // MARK: — 3. Генерация вариантов разбиения (для сложных задач)
    func generateSplittingVariants(taskJSON: String,
                                   completion: @escaping (Result<String, Error>) -> Void) {
        let now = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        let systemMessage = """
        Сегодня: \(now).
        Ты ассистент для обработки задач. Дана сложная задача в формате JSON:
        ---------------------
        \(taskJSON)
        ---------------------
        Твоя задача — предложить разбиение этой задачи на подзадачи. Каждая подзадача — это отдельный JSON-объект со следующими полями:
          - "название подзадачи": (String) - логически выведи из общей формулировки задачи
          - "начало подзадачи" и "конец подзадачи": (дата выполнения подзадачи в формате "yyyy-MM-dd HH:mm" **с 00:00 до 23:59 одного и того же дня**).
          - "место": ""
          - "время на дорогу": 0
          - "цвет категории": ""
          - "название категории": ""
          - "статус": "active"
          - "тип задачи": "userDefined"
          - "сложность": "простая"
        Дополнительные требования:
          - Равномерно распределяй подзадачи по доступному периоду выполнения.
          - Учитывай реальную длительность подзадач при планировании.
          - Разрешается ставить несколько подзадач в день, если это не создаст перегрузки для пользователя.
        Возвращай **только** список JSON‑объектов без дополнительных комментариев.
        """
        
        let messages = [ GPTChatMessage(role: "system", content: systemMessage) ]
        chatWithGPT(messages: messages, completion: completion)
    }
}

// MARK: — GPTService.swift

extension GPTService {

    /// true, если задача занимает 00:00–23:59
    private func isAllDay(_ task: [String: Any]) -> Bool {
        guard
            let sh = task["start"] as? String,
            let eh = task["end"]   as? String
        else { return false }
        return (sh == "00:00") && (eh == "23:59" || eh == "24:00" || eh == "00:00")
    }

    /// Рекомендации по вставке задач в указанный слот
    func recommendSlot(
            date: String,               // "yyyy-MM-dd"
            slotStart: String,          // "HH:mm"
            slotEnd: String,            // "HH:mm"
            tasks: [[String : Any]],    // title, start, end, deadline, duration_h
            dailyHours: [Int],          // часы за 7 дней (целые часы)
            completion: @escaping (Result<SlotRecommendation, Error>) -> Void
        ) {
            // 1) точная занятость сегодня (минуты; all-day и долгосрочные (>24 ч) не считаем)
            let busyMinutesToday = tasks
                .filter { !isAllDay($0) && ((($0["duration_h"] as? Int) ?? 0) <= TimeConstants.longTaskHourThreshold) }
                .reduce(0) { sum, t in
                    guard
                        let sh = t["start"] as? String,
                        let eh = t["end"]   as? String,
                        let s  = Self.timeFormatter.date(from: sh),
                        let e  = Self.timeFormatter.date(from: eh)
                    else { return sum }
                    return sum + Int(e.timeIntervalSince(s) / Double(TimeConstants.minutesPerHour))
                }
            
            // 2) готовим список задач строкой
            let taskList = tasks.map {
                "- \($0["title"] as? String ?? "") " +
                "(\($0["start"] as? String ?? "")–\($0["end"] as? String ?? "")), " +
                "дедлайн: \($0["deadline"] as? String ?? "")"
            }.joined(separator: "\n")
            
            // 3) строим system-prompt
            let minutesLast3 = dailyHours.suffix(
                TimeConstants.weeksWindow
            ).prefix(
                TimeConstants.daysWindow
            ).map {
                $0 * TimeConstants.minutesPerHour
            }
            let minutesNext3 = dailyHours.suffix(
                TimeConstants.daysWindow
            ).map {
                $0 * TimeConstants.minutesPerHour
            }
            
            let systemPrompt = """
                    Ты — персональный ассистент по тайм-менеджменту. Твоя цель — помогать пользователю **поддерживать баланс между работой и отдыхом**, **эффективно распределять задачи**, и **не допускать перегрузок**.

                    === ВХОДНЫЕ ДАННЫЕ ===
                    - Дата рекомендации: \(date)  
                    - Свободный слот: с \(slotStart) до \(slotEnd)  
                    - Уже занято сегодня: \(busyMinutesToday) минут  

                    - Нагрузка за 3 дня до \(date) (мину́ты): \(minutesLast3)  
                    - Нагрузка за 3 дня после \(date) (мину́ты): \(minutesNext3)  
                    - День считается перегруженным, если занятое время за день ≥ 360 минут. 
                    - Если занятое время на \(date) отличается **более чем на 30%** от среднего времени за последние 3 дня **и** следующие 3 дня, считай день тоже перегруженным.

                    - Список задач на \(date):  
                    \(taskList.isEmpty ? "— нет задач —" : taskList)

                    - Некоторые задачи могут быть рассчитаны на несколько дней. Разбивай их на разумные части, **рекомендуя прогресс по ним на текущий день**. Учитывай, что пользователь занимается ими **не только сегодня**, а в несколько подходов.

                    === ТВОЯ ЗАДАЧА ===
                    1. Если загрузка указывает на переутомление, верни `"recommendation":"rest"` с понятным объяснением.
                    2. Иначе подбери, чем заняться в этом слоте:
                       - Выбери до 3 задач:
                         - Приоритет у долгосрочных задач (`duration_h > 24`, дедлайн ≥ \(date)), которые можно выполнять по частям.
                         - Включай только актуальные задачи.
                         - Если в списке задач нет подходящих, можешь предложить **одну-две новые полезные идеи** (саморазвитие, уборка, прогулка и т.п.), помогающие продуктивно использовать время без перегрузки.
                       - Для каждой задачи укажи:
                         1. `title` — название задачи.  
                         2. `deadline` — дата дедлайна.  
                         3. `duration_h` — сколько часов **из свободного слота** можно потратить на задачу **сегодня**.  
                       - Убедись, что общее время задач не превышает длину слота и не перегружает пользователя.

                    3. Строго верни только валидный JSON:
                    ```json
                    {
                      "recommendation": "insert_task" | "rest",
                      "suggested": [
                        { "title": String, "deadline": String, "duration_h": Int }
                      ], // при "rest" здесь должен быть пустой массив
                      "message": String
                    }
                    ```
                    """
            
            let sysMsg = GPTChatMessage(role: "system", content: systemPrompt)
            
            // 4) запрос к GPT
            chatWithGPT(messages: [sysMsg], maxTokens: 400, temperature: 0.0) { result in
                switch result {
                case .failure(let err):
                    completion(.failure(err))
                    
                case .success(let text):
                    // удалить markdown-блоки ```json ... ```
                    let cleaned = text
                        .replacingOccurrences(of: "```json", with: "")
                        .replacingOccurrences(of: "```",     with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    print("GPT cleaned response:\n\(cleaned)\n")
                    
                    guard
                        let data = cleaned.data(using: .utf8),
                        let rec  = try? JSONDecoder().decode(SlotRecommendation.self, from: data)
                    else {
                        print("JSON parsing failed for cleaned response:\n\(cleaned)\n")
                        let parseErr = NSError(
                            domain: "GPTService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey:
                                "Не удалось распарсить JSON. Проверьте консоль."]
                        )
                        completion(.failure(parseErr))
                        return
                    }
                    
                    completion(.success(rec))
                }
            }
        }
        
        // Формат «HH:mm»
        private static let timeFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f
        }()
}


/// Модель ответа
struct SlotRecommendation: Codable {
    let recommendation: String       // "insert_task" или "rest"
    let suggested: [SuggestedTask]   // пуст, если rest
    let message: String
}

struct SuggestedTask: Codable {
    let title: String
    let deadline: String             // "yyyy-MM-dd"
    let duration_h: Int
}

