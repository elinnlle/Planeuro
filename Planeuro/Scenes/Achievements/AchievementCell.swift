//
//  AchievementCell.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 09.04.2025.
//

import UIKit

final class AchievementCell: UICollectionViewCell {

    // MARK: - Constants

    private enum Constants {
        static let circleDiameter: CGFloat    = 90
        static let progressBarHeight: CGFloat = 7
        static let titleSidePadding: CGFloat  = 4
        static let progressSidePadding: CGFloat = 12
        static let betweenElementsSpacing: CGFloat = 8
    }

    static let reuseId = "AchievementCell"

    // MARK: - UI Elements

    private let circleView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = Constants.circleDiameter / 2
        v.clipsToBounds = true
        return v
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "Nunito-Regular", size: 13)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 2
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.8
        return l
    }()

    private let progressBar: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.layer.cornerRadius = Constants.progressBarHeight / 2
        pv.clipsToBounds = true
        pv.trackTintColor = .color300
        pv.tintColor = .color500
        return pv
    }()

    private let progressLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont(name: "Nunito-Regular", size: 13)
        l.textAlignment = .center
        l.textColor = .color500
        return l
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        [circleView, imageView, titleLabel, progressBar, progressLabel]
            .forEach { contentView.addSubview($0) }
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }

    // MARK: - Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Круглая область / иконка
            circleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.widthAnchor.constraint(equalToConstant: Constants.circleDiameter),
            circleView.heightAnchor.constraint(equalToConstant: Constants.circleDiameter),

            imageView.topAnchor.constraint(equalTo: circleView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: circleView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: circleView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: circleView.bottomAnchor),

            // Заголовок
            titleLabel.topAnchor.constraint(
                equalTo: circleView.bottomAnchor,
                constant: Constants.betweenElementsSpacing),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.titleSidePadding),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.titleSidePadding),

            // Полоса прогресса
            progressBar.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Constants.betweenElementsSpacing),
            progressBar.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.progressSidePadding),
            progressBar.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.progressSidePadding),
            progressBar.heightAnchor.constraint(
                equalToConstant: Constants.progressBarHeight),

            // Текст прогресса
            progressLabel.topAnchor.constraint(
                equalTo: progressBar.bottomAnchor,
                constant: Constants.betweenElementsSpacing / 2),
            progressLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.titleSidePadding),
            progressLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.titleSidePadding),
            progressLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Configuration

    func configure(with model: Achievement) {
        // Перенос заголовка на две строки, если два слова
        let words = model.title.split(separator: " ")
        titleLabel.text = (words.count == 2)
            ? words.joined(separator: "\n")
            : model.title

        // Прогресс
        progressBar.setProgress(model.progress, animated: false)
        progressLabel.text = model.progressText

        // Иконка задание vs круг
        if let name = model.imageName {
            circleView.isHidden = true
            imageView.isHidden = false
            imageView.image = UIImage(named: name)
        } else {
            circleView.isHidden = false
            imageView.isHidden = true
            circleView.backgroundColor = .color300
        }
    }
}
