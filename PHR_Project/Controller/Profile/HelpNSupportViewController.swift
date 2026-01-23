//
//  HelpNSupportViewController.swift
//  PHR_Project
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class HelpNSupportViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fill
        return stack
    }()
    
    // MARK: - Data
    
    private let faqItems: [(question: String, answer: String)] = [
        ("Why can't I see my step count?", "To view your steps, you need to grant permission to access Apple HealthKit. Go to Settings > Privacy & Security > Health > PHR App and enable 'Steps'. Then return to the app and your step count will appear on the home screen.")
    ]
    
    private let contactOptions: [(icon: String, title: String, subtitle: String, tag: Int)] = [
        ("envelope.fill", "Email Support", "support@phrapp.com", 0),
        ("bubble.left.and.bubble.right.fill", "AI Chat", "Available 24/7", 2)
    ]

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupContent()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Help & Support"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
 
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Main Stack View
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupContent() {
        // FAQ Section
        let faqSection = createSectionContainer(title: "Frequently Asked Questions")
        for (index, item) in faqItems.enumerated() {
            let faqCard = createFAQCard(question: item.question, answer: item.answer, index: index)
            faqSection.addArrangedSubview(faqCard)
        }
        mainStackView.addArrangedSubview(faqSection)
        
        // Contact Section
        let contactSection = createSectionContainer(title: "Contact Support")
        for option in contactOptions {
            let contactCard = createContactCard(
                icon: option.icon,
                title: option.title,
                subtitle: option.subtitle,
                tag: option.tag
            )
            contactSection.addArrangedSubview(contactCard)
        }
        mainStackView.addArrangedSubview(contactSection)
        
        // Quick Links Section
        let quickLinksSection = createSectionContainer(title: "Quick Links")
        let links = [
            ("doc.text.fill", "Privacy Policy", "How we protect your data"),
            ("checkmark.shield.fill", "Terms of Service", "Our terms and conditions")
        ]
        for link in links {
            let linkCard = createQuickLinkCard(icon: link.0, title: link.1, subtitle: link.2)
            quickLinksSection.addArrangedSubview(linkCard)
        }
        mainStackView.addArrangedSubview(quickLinksSection)
        
        // App Info Section
        let appInfoSection = createAppInfoSection()
        mainStackView.addArrangedSubview(appInfoSection)
    }
    
    // MARK: - Card Creation Methods
    
    private func createSectionContainer(title: String) -> UIStackView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        container.distribution = .fill
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        
        container.addArrangedSubview(titleLabel)
        
        return container
    }
    
    private func createFAQCard(question: String, answer: String, index: Int) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = UIConstants.CornerRadius.medium
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = UIConstants.Shadow.defaultOpacity
        card.layer.shadowOffset = UIConstants.Shadow.defaultOffset
        card.layer.shadowRadius = UIConstants.Shadow.defaultRadius
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        
        let questionLabel = UILabel()
        questionLabel.text = "Q: \(question)"
        questionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        questionLabel.textColor = UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1)
        questionLabel.numberOfLines = 0
        
        let answerLabel = UILabel()
        answerLabel.text = "A: \(answer)"
        answerLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        answerLabel.textColor = .secondaryLabel
        answerLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(questionLabel)
        stackView.addArrangedSubview(answerLabel)
        
        card.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
    
    private func createContactCard(icon: String, title: String, subtitle: String, tag: Int) -> UIView {
        let card = UIButton(type: .system)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = UIConstants.CornerRadius.medium
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = UIConstants.Shadow.defaultOpacity
        card.layer.shadowOffset = UIConstants.Shadow.defaultOffset
        card.layer.shadowRadius = UIConstants.Shadow.defaultRadius
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1)
        iconImageView.contentMode = .scaleAspectFit
        
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 0.1)
        iconContainer.layer.cornerRadius = 25
        iconContainer.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        
        let chevronImageView = UIImageView()
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .tertiaryLabel
        chevronImageView.contentMode = .scaleAspectFit
        
        card.addSubview(iconContainer)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 50),
            iconContainer.heightAnchor.constraint(equalToConstant: 50),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            
            chevronImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        card.addTarget(self, action: #selector(handleContactAction(_:)), for: .touchUpInside)
        card.tag = tag
        
        return card
    }
    
    private func createQuickLinkCard(icon: String, title: String, subtitle: String) -> UIView {
        let card = UIButton(type: .system)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = UIConstants.CornerRadius.medium
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = UIConstants.Shadow.defaultOpacity
        card.layer.shadowOffset = UIConstants.Shadow.defaultOffset
        card.layer.shadowRadius = UIConstants.Shadow.defaultRadius
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1)
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        
        let chevronImageView = UIImageView()
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .tertiaryLabel
        chevronImageView.contentMode = .scaleAspectFit
        
        card.addSubview(iconImageView)
        card.addSubview(titleLabel)
        card.addSubview(subtitleLabel)
        card.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            
            chevronImageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 10),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        card.addTarget(self, action: #selector(handleQuickLinkTapped), for: .touchUpInside)
        
        return card
    }
    
    private func createAppInfoSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = UIConstants.CornerRadius.medium
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = UIConstants.Shadow.defaultOpacity
        container.layer.shadowOffset = UIConstants.Shadow.defaultOffset
        container.layer.shadowRadius = UIConstants.Shadow.defaultRadius
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        
        let appIconImageView = UIImageView()
        appIconImageView.translatesAutoresizingMaskIntoConstraints = false
        appIconImageView.image = UIImage(systemName: "heart.text.square.fill")
        appIconImageView.tintColor = UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1)
        appIconImageView.contentMode = .scaleAspectFit
        
        let appNameLabel = UILabel()
        appNameLabel.text = "Personal Health Record"
        appNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        appNameLabel.textColor = .label
        appNameLabel.textAlignment = .center
        
        let versionLabel = UILabel()
        versionLabel.text = "Version 1.0.0"
        versionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        versionLabel.textColor = .secondaryLabel
        versionLabel.textAlignment = .center
        
        let copyrightLabel = UILabel()
        copyrightLabel.text = "© 2026 PHR App. All rights reserved."
        copyrightLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        copyrightLabel.textColor = .tertiaryLabel
        copyrightLabel.textAlignment = .center
        
        stackView.addArrangedSubview(appIconImageView)
        stackView.addArrangedSubview(appNameLabel)
        stackView.addArrangedSubview(versionLabel)
        stackView.addArrangedSubview(copyrightLabel)
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            appIconImageView.widthAnchor.constraint(equalToConstant: 60),
            appIconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
        
        return container
    }
    
    // MARK: - Actions
    
    @objc private func handleContactAction(_ sender: UIButton) {
        var message = ""
        switch sender.tag {
        case 0: // Email
            message = "Opening email client..."
            // In a real app: if let url = URL(string: "mailto:support@phrapp.com") { UIApplication.shared.open(url) }
        case 1: // Phone
            message = "Opening phone dialer..."
            // In a real app: if let url = URL(string: "tel://18001234567") { UIApplication.shared.open(url) }
        case 2: // Chat
            message = "Starting live chat..."
        case 3: // Website
            message = "Opening website..."
            // In a real app: if let url = URL(string: "https://www.phrapp.com") { UIApplication.shared.open(url) }
        default:
            message = "Unknown action"
        }
        
        showAlert(title: "Contact Support", message: message)
    }
    
    @objc private func handleQuickLinkTapped() {
        showAlert(title: "Quick Link", message: "Opening document...")
    }

}
