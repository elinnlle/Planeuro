//
//  SettingsViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 07.03.2025.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate {
    
    // MARK: - Свойства
    
    var interactor: SettingsInteractor!
    let presenter = SettingsPresenter()
    
    // UI элементы
    public private(set) var bottomBarManager: BottomBarManager!
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var wakeUpLabel: UILabel!
    private var sleepLabel: UILabel!
    
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
        
        // Отобразить время по умолчанию
        presenter.presentWakeUpTime(date: interactor.wakeUpTime)
        presenter.presentSleepTime(date: interactor.sleepTime)
    }
    
    // MARK: - Настройка UI
    
    private func setupUI() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        
        contentView = UIView()
        scrollView.addSubview(contentView)
        
        let profileImageView = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        profileImageView.tintColor = .color500
        contentView.addSubview(profileImageView)
        
        let nameLabel = UILabel()
        nameLabel.text = "Имя пользователя"
        nameLabel.textColor = .color800
        nameLabel.font = UIFont(name: "Nunito-ExtraBold", size: Constants.titleFontSize)
        contentView.addSubview(nameLabel)
        
        let emailLabel = UILabel()
        emailLabel.text = "name@pochta.ru"
        emailLabel.font = UIFont(name: "Nunito-Regular", size: Constants.subtitleFontSize)
        emailLabel.textColor = .black
        contentView.addSubview(emailLabel)
        
        // Кнопка редактирования
        let editButton = UIButton(type: .system)
        editButton.backgroundColor = .white
        editButton.layer.borderColor = UIColor.color500.cgColor
        editButton.layer.borderWidth = Constants.lineHeight
        editButton.layer.cornerRadius = Constants.cornerRadius
        
        // Стек для иконки и текста
        let editButtonStackView = UIStackView()
        editButtonStackView.axis = .horizontal
        editButtonStackView.alignment = .center
        editButtonStackView.distribution = .equalSpacing
        editButtonStackView.spacing = Constants.smallSpacing
        
        let editLabel = UILabel()
        editLabel.text = "Редактировать"
        editLabel.textColor = .black
        editLabel.font = UIFont.systemFont(ofSize: Constants.labelFontSize)
        editButtonStackView.addArrangedSubview(editLabel)
        
        let pencilIcon = UIImageView(image: UIImage(named: "PencilIcon"))
        pencilIcon.contentMode = .scaleAspectFit
        editButtonStackView.addArrangedSubview(pencilIcon)
        
        editButton.addSubview(editButtonStackView)
        contentView.addSubview(editButton)
        
        let line1 = createLine()
        contentView.addSubview(line1)
        
        let statsButton = createCustomButton(title: "Посмотреть", subtitle: "Статистику")
        contentView.addSubview(statsButton)
        
        let achievementsButton = createCustomButton(title: "Посмотреть", subtitle: "Достижения")
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
        
        let pushCheckbox = createCheckbox(isChecked: false)
        let pushLabel = UILabel()
        pushLabel.text = "Push-уведомления"
        pushLabel.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        pushLabel.textColor = .black
        contentView.addSubview(pushCheckbox)
        contentView.addSubview(pushLabel)
        
        let emailCheckbox = createCheckbox(isChecked: false)
        let emailLabelSwitch = UILabel()
        emailLabelSwitch.text = "Электронная почта"
        emailLabelSwitch.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        emailLabelSwitch.textColor = .black
        contentView.addSubview(emailCheckbox)
        contentView.addSubview(emailLabelSwitch)
        
        let recomendationCheckbox = createCheckbox(isChecked: false)
        let recomendationLabelSwitch = UILabel()
        recomendationLabelSwitch.text = "Уведомления с рекомендациями"
        recomendationLabelSwitch.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        recomendationLabelSwitch.textColor = .black
        contentView.addSubview(recomendationCheckbox)
        contentView.addSubview(recomendationLabelSwitch)
        
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
        
        let recommendationsSegmentedControl = UISegmentedControl(items: ["Нужны", "Не нужны"])
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
        contactUsLabel.text = "Связь с нами"
        contactUsLabel.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        contactUsLabel.textColor = .black
        contentView.addSubview(contactUsLabel)
        
        let contactUsButton = UIImageView(image: UIImage(named: "RightIcon"))
        contactUsButton.contentMode = .scaleAspectFit
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
        
        editButton.pinCenterX(to: contentView)
        editButton.pinTop(to: emailLabel.bottomAnchor, Constants.spacing)
        editButton.setWidth(Constants.editButtonWidth)
        editButton.setHeight(Constants.editButtonHeight)
        
        editButtonStackView.pinCenter(to: editButton)
        editButtonStackView.pinLeft(to: editButton.leadingAnchor, Constants.spacing, .grOE)
        editButtonStackView.pinRight(to: editButton.trailingAnchor, Constants.spacing, .lsOE)
        
        line1.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        line1.pinRight(to: contentView.trailingAnchor, Constants.largeSpacing)
        line1.pinTop(to: editButton.bottomAnchor, Constants.largeSpacing)
        
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
        
        recomendationCheckbox.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        recomendationCheckbox.pinTop(to: emailCheckbox.bottomAnchor, Constants.spacing)
        
        recomendationLabelSwitch.pinLeft(to: recomendationCheckbox.trailingAnchor, Constants.spacing)
        recomendationLabelSwitch.pinCenterY(to: recomendationCheckbox)
        
        line3.pinLeft(to: contentView.leadingAnchor, Constants.largeSpacing)
        line3.pinRight(to: contentView.trailingAnchor, Constants.largeSpacing)
        line3.pinTop(to: recomendationLabelSwitch.bottomAnchor, Constants.largeSpacing)
        
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
        alertController.view.tintColor = UIColor.color700
        
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
    }
    
    private func createLine() -> UIView {
        let line = UIView()
        line.backgroundColor = .color500
        line.setHeight(Constants.lineHeight)
        return line
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            print("Нужны")
        } else {
            print("Не нужны")
        }
    }
}

// MARK: - Расширение для протокола SettingsView

extension SettingsViewController: SettingsView {
    func displayWakeUpTime(_ time: String) {
        wakeUpLabel.text = time
    }
    
    func displaySleepTime(_ time: String) {
        sleepLabel.text = time
    }
}

