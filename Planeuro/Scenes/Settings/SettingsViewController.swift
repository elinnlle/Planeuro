//
//  SettingsViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 07.03.2025.
//

import UIKit
import PhotosUI
import CoreData

class SettingsViewController: UIViewController,
                              UITableViewDelegate,
                              UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate {
    
    // MARK: - Свойства
    
    var interactor: SettingsInteractor!
    let presenter = SettingsPresenter()
    
    // UI элементы
    public private(set) var bottomBarManager: BottomBarManager!
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    
    private var profileImageView: UIImageView!
    private var nameLabel: UILabel!
    private var emailLabel: UILabel!
    private var pushCheckbox: UIButton!
    private var emailCheckbox: UIButton!
    private var wakeUpLabel: UILabel!
    private var sleepLabel: UILabel!
    private let recommendationsSegmentedControl = UISegmentedControl(items: ["Нужны", "Не нужны"])
    
    private let taskInteractor = TaskInteractor()
    
    // MARK: - Константы
    
    private enum Constants {
        static let defaultWakeUpHour = 10
        static let defaultWakeUpMinute = 0
        static let defaultSleepHour = 22
        static let defaultSleepMinute = 0
        static let profileImageSize: CGFloat = 70
        static let editButtonWidth: CGFloat = 174
        static let editButtonHeight: CGFloat = 40
        static let statsButtonWidth: CGFloat = 171
        static let statsButtonHeight: CGFloat = 63
        static let iconSize: CGFloat = 30
        static let lineHeight: CGFloat = 1
        static let segmentedControlHeight: CGFloat = 35
        static let datePickerWidth: CGFloat = 280
        static let datePickerHeight: CGFloat = 216
        static let checkboxSize: CGSize = CGSize(width: 18, height: 18)
        static let cornerRadius: CGFloat = 20
        static let spacing: CGFloat = 10
        static let largeSpacing: CGFloat = 20
        static let pencilSpacing: CGFloat = -25
        static let smallSpacing: CGFloat = 5
        static let titleFontSize: CGFloat = 27
        static let subtitleFontSize: CGFloat = 20
        static let buttonTitleFontSize: CGFloat = 14
        static let buttonSubtitleFontSize: CGFloat = 20
        static let labelFontSize: CGFloat = 17
        static let footerFontSize: CGFloat = 14
    }
    
    // MARK: - Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        // Настройка BottomBarManager (конфигурация как в оригинале)
        let customConfig = BottomBarConfiguration(
            icons: ["HomeIconAdd", "CalendarIconAdd", "SettingsIcon"],
            gradientImage: "Gradient"
        )
        bottomBarManager = BottomBarManager(view: self.view, configuration: customConfig)
        scrollView.delegate = self
        
        // Инициализация presenter и interactor
        presenter.view = self
        interactor = SettingsInteractor(presenter: presenter)
        
        UserDefaults.standard.register(defaults: [
              "pushNotificationsEnabled": false,
              "emailNotificationsEnabled": false
        ])
            // 2) Устанавливаем состояние чекбоксов
        pushCheckbox.isSelected  = UserDefaults.standard.bool(forKey: "pushNotificationsEnabled")
        emailCheckbox.isSelected = UserDefaults.standard.bool(forKey: "emailNotificationsEnabled")
        
        // Отобразить время по умолчанию
        presenter.presentWakeUpTime(date: interactor.wakeUpTime)
        presenter.presentSleepTime(date: interactor.sleepTime)
        
        let enabled = UserDefaults.standard.object(forKey: "recommendationsEnabled") as? Bool ?? true
        recommendationsSegmentedControl.selectedSegmentIndex = enabled ? 0 : 1
        
        // загрузить сохранённую фотографию
            if let data = UserDefaults.standard.data(forKey: "userPhoto"),
               let image = UIImage(data: data) {
                profileImageView.image = image
        }
    }
    
    // MARK: - Настройка UI
    
    private func setupUI() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        
        contentView = UIView()
        scrollView.addSubview(contentView)
        
        profileImageView = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        profileImageView.tintColor = .color500
        profileImageView.layer.cornerRadius = Constants.profileImageSize/2
        profileImageView.clipsToBounds = true
        contentView.addSubview(profileImageView)
        
        nameLabel = UILabel()
        nameLabel.textColor = .color800
        nameLabel.font = UIFont(name: "Nunito-ExtraBold", size: Constants.titleFontSize)
        contentView.addSubview(nameLabel)
        
        emailLabel = UILabel()
        emailLabel.font = UIFont(name: "Nunito-Regular", size: Constants.subtitleFontSize)
        emailLabel.textColor = .black
        contentView.addSubview(emailLabel)
        
        let line1 = createLine()
        contentView.addSubview(line1)
        
        let statsButton = createCustomButton(title: "Редактировать", subtitle: "Аккаунт")
        statsButton.addTarget(self,
                              action: #selector(editAccountTapped),
                              for: .touchUpInside)
        contentView.addSubview(statsButton)
        
        let achievementsButton = createCustomButton(title: "Посмотреть", subtitle: "Достижения")
        achievementsButton.addTarget(self,
                                     action: #selector(achievementsTapped),
                                     for: .touchUpInside)
        contentView.addSubview(achievementsButton)
        
        let line2 = createLine()
        contentView.addSubview(line2)
        
        let notificationsIcon = UIImageView(image: UIImage(named: "BellIcon"))
        notificationsIcon.contentMode = .scaleAspectFit
        contentView.addSubview(notificationsIcon)
        
        let notificationsLabel = UILabel()
        notificationsLabel.text = "Уведомления"
        notificationsLabel.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        notificationsLabel.textColor = .black
        contentView.addSubview(notificationsLabel)
        
        pushCheckbox = createCheckbox(
            isChecked: UserDefaults.standard.bool(forKey: "pushNotificationsEnabled"))
        let pushLabel = UILabel()
        pushLabel.text = "Push-уведомления"
        pushLabel.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        pushLabel.textColor = .black
        contentView.addSubview(pushCheckbox)
        contentView.addSubview(pushLabel)
        
        emailCheckbox = createCheckbox(
            isChecked: UserDefaults.standard.bool(forKey: "emailNotificationsEnabled"))
        let emailLabelSwitch = UILabel()
        emailLabelSwitch.text = "Электронная почта"
        emailLabelSwitch.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        emailLabelSwitch.textColor = .black
        contentView.addSubview(emailCheckbox)
        contentView.addSubview(emailLabelSwitch)
        
        let line3 = createLine()
        contentView.addSubview(line3)
        
        let recommendationsIcon = UIImageView(image: UIImage(named: "LampIcon"))
        recommendationsIcon.contentMode = .scaleAspectFit
        contentView.addSubview(recommendationsIcon)
        
        let recommendationsLabel = UILabel()
        recommendationsLabel.text = "Рекомендации"
        recommendationsLabel.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        recommendationsLabel.textColor = .black
        contentView.addSubview(recommendationsLabel)
        
        recommendationsSegmentedControl.selectedSegmentIndex = 0
        recommendationsSegmentedControl.backgroundColor = .color200
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)!,
            .foregroundColor: UIColor.color800
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)!,
            .foregroundColor: UIColor.black
        ]
        recommendationsSegmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        recommendationsSegmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        recommendationsSegmentedControl.selectedSegmentTintColor = .white
        recommendationsSegmentedControl.layer.cornerRadius = Constants.cornerRadius
        recommendationsSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        contentView.addSubview(recommendationsSegmentedControl)
        
        let line4 = createLine()
        contentView.addSubview(line4)
        
        let dayModeIcon = UIImageView(image: UIImage(named: "BedIcon"))
        dayModeIcon.contentMode = .scaleAspectFit
        dayModeIcon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayModeIcon)
        
        let dayModeLabel = UILabel()
        dayModeLabel.text = "Режим дня"
        dayModeLabel.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        dayModeLabel.textColor = .black
        contentView.addSubview(dayModeLabel)
        
        wakeUpLabel = UILabel()
        wakeUpLabel.text = "Подъём 10:00"
        wakeUpLabel.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        wakeUpLabel.textColor = .black
        contentView.addSubview(wakeUpLabel)
        
        let wakeUpEditButton = UIImageView(image: UIImage(named: "PencilIcon"))
        wakeUpEditButton.contentMode = .scaleAspectFit
        wakeUpEditButton.isUserInteractionEnabled = true
        let wakeUpEditTap = UITapGestureRecognizer(target: self, action: #selector(editWakeUpTime))
        wakeUpEditButton.addGestureRecognizer(wakeUpEditTap)
        contentView.addSubview(wakeUpEditButton)
        
        sleepLabel = UILabel()
        sleepLabel.text = "Отход ко сну 22:00"
        sleepLabel.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        sleepLabel.textColor = .black
        contentView.addSubview(sleepLabel)
        
        let sleepEditButton = UIImageView(image: UIImage(named: "PencilIcon"))
        sleepEditButton.contentMode = .scaleAspectFit
        sleepEditButton.isUserInteractionEnabled = true
        let sleepEditTap = UITapGestureRecognizer(target: self, action: #selector(editSleepTime))
        sleepEditButton.addGestureRecognizer(sleepEditTap)
        contentView.addSubview(sleepEditButton)
        
        let line5 = createLine()
        contentView.addSubview(line5)
        
        let contactUsIcon = UIImageView(image: UIImage(named: "MailIcon"))
        contactUsIcon.contentMode = .scaleAspectFit
        contentView.addSubview(contactUsIcon)
        
        let contactUsLabel = UILabel()
        contactUsLabel.text = "Обратная связь"
        contactUsLabel.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        contactUsLabel.textColor = .black
        contentView.addSubview(contactUsLabel)
        
        let contactUsButton = UIImageView(image: UIImage(named: "RightIcon"))
        contactUsButton.contentMode = .scaleAspectFit
        contactUsButton.isUserInteractionEnabled = true
        let contactTap = UITapGestureRecognizer(target: self, action: #selector(contactUsTapped))
        contactUsButton.addGestureRecognizer(contactTap)
        contentView.addSubview(contactUsButton)
        
        let line6 = createLine()
        contentView.addSubview(line6)
        
        let footerLabel = UILabel()
        footerLabel.text = """
        Planeuro
        Разработчик: Матвеенко Эльвира
        Версия 1.0.0
        """
        footerLabel.textAlignment = .center
        footerLabel.numberOfLines = 0
        footerLabel.font = UIFont(name: "Nunito-Regular", size: Constants.footerFontSize)
        footerLabel.textColor = .black
        contentView.addSubview(footerLabel)
        
        // Применяем layout-констрейнты (предполагается, что методы pin* реализованы)
        scrollView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        scrollView.pinLeft(to: view.leadingAnchor)
        scrollView.pinRight(to: view.trailingAnchor)
        scrollView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
        
        contentView.pinTop(to: scrollView.topAnchor)
        contentView.pinLeft(to: scrollView.leadingAnchor)
        contentView.pinRight(to: scrollView.trailingAnchor)
        contentView.pinBottom(to: scrollView.bottomAnchor)
        contentView.pinWidth(to: scrollView)
        
        profileImageView.pinCenterX(to: contentView)
        profileImageView.pinTop(to: contentView.topAnchor, Constants.largeSpacing)
        profileImageView.setWidth(Constants.profileImageSize)
        profileImageView.setHeight(Constants.profileImageSize)
        
        nameLabel.pinCenterX(to: contentView)
        nameLabel.pinTop(to: profileImageView.bottomAnchor)
        
        emailLabel.pinCenterX(to: contentView)
        emailLabel.pinTop(to: nameLabel.bottomAnchor)
        
        line1.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        line1.pinRight(to: contentView.trailingAnchor, Constants.largeSpacing)
        line1.pinTop(to: emailLabel.bottomAnchor, Constants.largeSpacing)
        
        statsButton.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        statsButton.pinTop(to: line1.bottomAnchor, Constants.largeSpacing)
        statsButton.setWidth(Constants.statsButtonWidth)
        statsButton.setHeight(Constants.statsButtonHeight)
        
        achievementsButton.pinRight(to: contentView.trailingAnchor, Constants.largeSpacing)
        achievementsButton.pinTop(to: line1.bottomAnchor, Constants.largeSpacing)
        achievementsButton.setWidth(Constants.statsButtonWidth)
        achievementsButton.setHeight(Constants.statsButtonHeight)
        
        line2.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        line2.pinRight(to: contentView.trailingAnchor, Constants.largeSpacing)
        line2.pinTop(to: statsButton.bottomAnchor, Constants.largeSpacing)
        
        notificationsIcon.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        notificationsIcon.pinTop(to: line2.bottomAnchor, Constants.largeSpacing)
        notificationsIcon.setWidth(Constants.iconSize)
        notificationsIcon.setHeight(Constants.iconSize)
        
        notificationsLabel.pinLeft(to: notificationsIcon.trailingAnchor, Constants.spacing)
        notificationsLabel.pinCenterY(to: notificationsIcon)
        
        pushCheckbox.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        pushCheckbox.pinTop(to: notificationsLabel.bottomAnchor, Constants.spacing)
        
        pushLabel.pinLeft(to: pushCheckbox.trailingAnchor, Constants.spacing)
        pushLabel.pinCenterY(to: pushCheckbox)
        
        emailCheckbox.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        emailCheckbox.pinTop(to: pushCheckbox.bottomAnchor, Constants.spacing)
        
        emailLabelSwitch.pinLeft(to: emailCheckbox.trailingAnchor, Constants.spacing)
        emailLabelSwitch.pinCenterY(to: emailCheckbox)
        
        line3.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        line3.pinRight(to: contentView.trailingAnchor, Constants.largeSpacing)
        line3.pinTop(to: emailLabelSwitch.bottomAnchor, Constants.largeSpacing)
        
        recommendationsIcon.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        recommendationsIcon.pinTop(to: line3.bottomAnchor, Constants.largeSpacing)
        recommendationsIcon.setWidth(Constants.iconSize)
        recommendationsIcon.setHeight(Constants.iconSize)
        
        recommendationsLabel.pinLeft(to: recommendationsIcon.trailingAnchor, Constants.spacing)
        recommendationsLabel.pinCenterY(to: recommendationsIcon)
        
        recommendationsSegmentedControl.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        recommendationsSegmentedControl.pinTop(to: recommendationsLabel.bottomAnchor, Constants.spacing)
        recommendationsSegmentedControl.pinRight(to: contentView.trailingAnchor, Constants.largeSpacing)
        recommendationsSegmentedControl.setHeight(Constants.segmentedControlHeight)
        
        line4.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        line4.pinRight(to: contentView.trailingAnchor, Constants.largeSpacing)
        line4.pinTop(to: recommendationsSegmentedControl.bottomAnchor, Constants.largeSpacing)
        
        dayModeIcon.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        dayModeIcon.pinTop(to: line4.bottomAnchor, Constants.largeSpacing)
        dayModeIcon.setWidth(Constants.iconSize)
        dayModeIcon.setHeight(Constants.iconSize)
        
        dayModeLabel.pinLeft(to: dayModeIcon.trailingAnchor, Constants.spacing)
        dayModeLabel.pinCenterY(to: dayModeIcon)
        
        wakeUpLabel.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        wakeUpLabel.pinTop(to: dayModeLabel.bottomAnchor, Constants.spacing)
        
        wakeUpEditButton.pinRight(to: wakeUpLabel.trailingAnchor, Constants.pencilSpacing)
        wakeUpEditButton.pinCenterY(to: wakeUpLabel)
        
        sleepLabel.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        sleepLabel.pinTop(to: wakeUpLabel.bottomAnchor, Constants.spacing)
        
        sleepEditButton.pinRight(to: sleepLabel.trailingAnchor, Constants.pencilSpacing)
        sleepEditButton.pinCenterY(to: sleepLabel)
        
        line5.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        line5.pinRight(to: contentView.trailingAnchor, Constants.largeSpacing)
        line5.pinTop(to: sleepLabel.bottomAnchor, Constants.largeSpacing)
        
        contactUsIcon.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        contactUsIcon.pinTop(to: line5.bottomAnchor, Constants.largeSpacing)
        contactUsIcon.setWidth(Constants.iconSize)
        contactUsIcon.setHeight(Constants.iconSize)
        
        contactUsLabel.pinLeft(to: contactUsIcon.trailingAnchor, Constants.spacing)
        contactUsLabel.pinCenterY(to: contactUsIcon)
        
        contactUsButton.pinRight(to: contentView.trailingAnchor, Constants.largeSpacing)
        contactUsButton.pinCenterY(to: contactUsLabel)
        
        line6.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        line6.pinRight(to: contentView.trailingAnchor, Constants.largeSpacing)
        line6.pinTop(to: contactUsLabel.bottomAnchor, Constants.largeSpacing)
        
        footerLabel.pinTop(to: line6.bottomAnchor, Constants.largeSpacing)
        footerLabel.pinCenterX(to: contentView)
        footerLabel.pinBottom(to: contentView.bottomAnchor, Constants.largeSpacing)
    }
    
    // MARK: — Actions

    @objc private func editAccountTapped() {
        let sheet = UIAlertController(
            title: "Редактирование аккаунта",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        sheet.view.tintColor = .color700

        sheet.addAction(.init(title: "Изменить фото", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        })

        sheet.addAction(.init(title: "Изменить имя", style: .default) { [weak self] _ in
            self?.presentNameEditor()
        })

        sheet.addAction(.init(title: "Выйти из аккаунта", style: .default) { [weak self] _ in
            self?.performLogout()
        })

        sheet.addAction(.init(title: "Удалить аккаунт", style: .default) { [weak self] _ in
            self?.confirmDeleteAccount()
        })

        sheet.addAction(.init(title: "Отмена", style: .cancel))
        present(sheet, animated: true)
    }
    
    // MARK: — Photo Picker

    private func presentPhotoPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true          // встроенный square-crop
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController,
                                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        // получаем отредактированное изображение или оригинал
        let img = (info[.editedImage] as? UIImage)
            ?? (info[.originalImage] as? UIImage)
        guard let image = img else { return }

        // если нужен доп. кроп в коде:
        let square = cropToSquare(image: image)

        profileImageView.image = square

        // сохраняем в UserDefaults
        if let data = square.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: "userPhoto")
        }
    }

    private func cropToSquare(image: UIImage) -> UIImage {
        let original = image
        let side = min(original.size.width, original.size.height)
        let x = (original.size.width - side)  / 2.0
        let y = (original.size.height - side) / 2.0
        let cropRect = CGRect(x: x * original.scale,
                              y: y * original.scale,
                              width: side * original.scale,
                              height: side * original.scale)
        guard let cg = original.cgImage?.cropping(to: cropRect) else {
            return original
        }
        return UIImage(cgImage: cg,
                       scale: original.scale,
                       orientation: original.imageOrientation)
    }
    
    // MARK: — Edit Name

    private func presentNameEditor() {
        let alert = UIAlertController(
            title: "Новое имя",
            message: "Введите имя пользователя",
            preferredStyle: .alert
        )
        alert.view.tintColor = .color700
        
        alert.addTextField { tf in
            tf.placeholder = "Имя"
            tf.text = self.nameLabel.text
        }
        alert.addAction(.init(title: "Отмена", style: .cancel))
        alert.addAction(.init(title: "Сохранить", style: .default) { _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                self.nameLabel.text = newName
                UserDefaults.standard.set(newName, forKey: "userName")
            }
        })
        present(alert, animated: true)
    }
    
    @objc private func achievementsTapped() {
        let vc = AchievementsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: — Logout

    private func performLogout() {
        AuthManager.shared.setUserLoggedIn(false)
        goToLoginScreen()
    }

    // MARK: — Delete Account

    private func confirmDeleteAccount() {
        let alert = UIAlertController(
            title: "Удалить аккаунт?",
            message: "Все данные будут безвозвратно удалены.",
            preferredStyle: .alert
        )
        alert.view.tintColor = .color700
        alert.addAction(.init(title: "Отмена", style: .cancel))
        alert.addAction(.init(title: "Удалить", style: .default) { _ in
            self.deleteAllUserData()
            AuthManager.shared.deleteAccount { _ in
                DispatchQueue.main.async {
                    self.goToLoginScreen()
                }
            }
        })
        present(alert, animated: true)
    }
    
    private func deleteAllUserData() {
        let defaults = UserDefaults.standard

        // 1) Удаляем все задачи
        taskInteractor.fetchTasks().forEach { taskInteractor.deleteTask($0) }

        // 2) Удаляем сохранённые учётные данные из Keychain
        if let email = defaults.string(forKey: "userEmail") {
            // удаляем пару (email ↔︎ password)
            try? KeychainHelper.delete(account: email)
        }
        // 3) Удаляем текущую сессию
        try? KeychainHelper.delete(account: "__session__")

        // 4) Чистим всё из UserDefaults
        [
          "userName",
          "userEmail",
          "wakeUpTime",
          "sleepTime",
          "recommendationsEnabled",
          "userPhoto"
        ].forEach { defaults.removeObject(forKey: $0) }
    }


    private func goToLoginScreen() {
        // 1) создаём логик-слой для Login
        let loginPresenter = LoginPresenter()
        let loginInteractor = LoginInteractor(presenter: loginPresenter)
        // 2) инициализируем LoginViewController нужным init(interactor:presenter:)
        let loginVC = LoginViewController(interactor: loginInteractor,
                                          presenter: loginPresenter)
        // 3) показываем его во весь экран
        loginVC.modalPresentationStyle = .fullScreen
        if let nav = navigationController {
            nav.setViewControllers([loginVC], animated: true)
        } else {
            present(loginVC, animated: true)
        }
    }
    
    // MARK: - Действия с временем
    
    @objc private func editWakeUpTime() {
        showTimePicker(for: .wakeUp)
    }
    
    @objc private func editSleepTime() {
        showTimePicker(for: .sleep)
    }
    
    private enum TimeType {
        case wakeUp
        case sleep
    }
    
    private func showTimePicker(for timeType: TimeType) {
        let alertController = UIAlertController(
            title: "Выберите время",
            message: "\n\n\n\n\n\n\n\n\n\n\n",
            preferredStyle: .alert
        )
        
        let datePicker = UIDatePicker(
            frame: CGRect(
                x: 0,
                y: 0,
                width: Constants.datePickerWidth,
                height: Constants.datePickerHeight
            )
        )
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        
        switch timeType {
        case .wakeUp:
            datePicker.date = interactor.wakeUpTime
        case .sleep:
            datePicker.date = interactor.sleepTime
        }
        
        alertController.view.addSubview(datePicker)
        datePicker.pinCenter(to: alertController.view)
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            switch timeType {
            case .wakeUp:
                self.interactor.updateWakeUpTime(to: datePicker.date)
            case .sleep:
                self.interactor.updateSleepTime(to: datePicker.date)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Действие "Обратная связь"
    @objc private func contactUsTapped() {
        guard let url = URL(string: "https://t.me/your_elya") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Вдруг URL не открывается — можно показать алерт
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Не удалось открыть Telegram.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    // MARK: - Создание UI-компонентов
    
    private func createCustomButton(title: String, subtitle: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.color500.cgColor
        button.layer.borderWidth = Constants.lineHeight
        button.layer.cornerRadius = Constants.cornerRadius
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Nunito-Regular", size: Constants.buttonTitleFontSize)
        titleLabel.textColor = .black
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont(name: "Nunito-ExtraBold", size: Constants.buttonSubtitleFontSize)
        subtitleLabel.textColor = .color800
        
        button.addSubview(titleLabel)
        button.addSubview(subtitleLabel)
        
        titleLabel.pinCenterX(to: button.centerXAnchor)
        titleLabel.pinTop(to: button.topAnchor, Constants.spacing)
        subtitleLabel.pinCenterX(to: button.centerXAnchor)
        subtitleLabel.pinTop(to: titleLabel.bottomAnchor, Constants.smallSpacing)
        subtitleLabel.pinBottom(to: button.bottomAnchor, Constants.spacing)
        
        return button
    }
    
    private func createCheckbox(isChecked: Bool) -> UIButton {
        let checkbox = UIButton(type: .custom)
        let uncheckedImage = UIImage(systemName: "square")?.withTintColor(UIColor.color800, renderingMode: .alwaysOriginal)
        let checkedImage = UIImage(systemName: "checkmark.square")?.withTintColor(UIColor.color800, renderingMode: .alwaysOriginal)
        
        checkbox.setImage(uncheckedImage, for: .normal)
        checkbox.setImage(checkedImage, for: .selected)
        checkbox.isSelected = isChecked
        checkbox.layer.cornerRadius = Constants.cornerRadius / 4
        checkbox.layer.borderColor = UIColor.color800.cgColor
        checkbox.frame.size = Constants.checkboxSize
        checkbox.addTarget(self, action: #selector(toggleCheckbox(_:)), for: .touchUpInside)
        return checkbox
    }
    
    @objc private func toggleCheckbox(_ sender: UIButton) {
        sender.isSelected.toggle()
        let defaults = UserDefaults.standard

        if sender == pushCheckbox {
            // 1) Сохраняем в UserDefaults
            defaults.set(sender.isSelected, forKey: "pushNotificationsEnabled")

            let center = UNUserNotificationCenter.current()
            let service = TasksService()

            if sender.isSelected {
                // 2a) Если включили — сразу планируем push для всех существующих задач
                let allTasks = service.getAllTasks()
                allTasks.forEach { task in
                    let newIDs = NotificationManager.shared.scheduleLocalNotifications(for: task)
                    service.updateReminderIDs(for: task, with: newIDs)
                }
            } else {
                // 2b) Если выключили — отменяем все запланированные локальные уведомления
                center.removeAllPendingNotificationRequests()
                // (Опционально) Обнуляем сохранённые IDs в Core Data, чтобы не было висячих
                let allTasks = service.getAllTasks()
                allTasks.forEach { task in
                    service.updateReminderIDs(for: task, with: [])
                }
            }
        }
        else if sender == emailCheckbox {
            defaults.set(sender.isSelected, forKey: "emailNotificationsEnabled")
            // e-mail уведомления мы всё равно не отправим в BG-таске,
            // потому что там стоит guard по этому флагу
        }
    }
    
    private func createLine() -> UIView {
        let line = UIView()
        line.backgroundColor = .color500
        line.setHeight(Constants.lineHeight)
        return line
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let wantsRecs = sender.selectedSegmentIndex == 0
        UserDefaults.standard.set(wantsRecs, forKey: "recommendationsEnabled")
        print(wantsRecs ? "Рекомендации включены" : "Рекомендации отключены")
    }
}

// MARK: - Расширение для протокола SettingsView

extension SettingsViewController: SettingsView {
    func displayProfile(name: String, email: String) {
        nameLabel.text = name
        emailLabel.text = email
    }
    
    func displayWakeUpTime(_ time: String) {
        wakeUpLabel.text = time
    }
    
    func displaySleepTime(_ time: String) {
        sleepLabel.text = time
    }
}
