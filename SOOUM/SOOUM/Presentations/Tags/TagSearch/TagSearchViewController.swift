//
//  TagSearchViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/26/24.
//

import UIKit

class TagSearchViewController: BaseViewController {
    
    let backButton = UIButton().then {
        $0.setImage(.arrowBackOutlined, for: .normal)
        $0.tintColor = .som.black
    }
    
    let hideKeyboardUIBarButton = UIBarButtonItem().then {
        $0.title = "완료"
        $0.style = .done
    }
    
    let tagSearchTextFieldView = TagSearchTextFieldView(isInteractive: true)

    lazy var tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.sectionHeaderTopPadding = 0
        $0.contentInset.top = 28
        $0.register(
            RecommendTagTableViewCell.self,
            forCellReuseIdentifier: String(
                describing: RecommendTagTableViewCell.self
            )
        )
        $0.dataSource = self
        $0.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupToolbar()
    }
    
    func setupToolbar() {
        // 툴바 생성
        let toolbar = UIToolbar()
        toolbar.sizeToFit() // 툴바 크기를 자동으로 조정
        
        // 툴바 버튼 생성

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) // 가운데 공간 확보
        
        // 버튼 추가
        toolbar.items = [flexibleSpace, self.hideKeyboardUIBarButton]
        
        // 텍스트 필드에 툴바 추가
        self.tagSearchTextFieldView.textField.inputAccessoryView = toolbar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tagSearchTextFieldView.textField.becomeFirstResponder()
        UIView.animate(withDuration: 0.1) {
            self.backButton.snp.updateConstraints {
                $0.size.equalTo(40)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    override func bind() {
        backButton.rx.tap
            .subscribe(with: self) { object, _ in
                UIView.animate(withDuration: 0.1) {
                    object.backButton.snp.updateConstraints {
                        $0.size.equalTo(0)
                    }
                    object.view.layoutIfNeeded()
                } completion: { _ in
                    object.dismiss(animated: true)
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.view.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(0)
        }
        
        self.view.addSubview(tagSearchTextFieldView)
        tagSearchTextFieldView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalTo(backButton.snp.trailing)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(backButton)
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.tagSearchTextFieldView.snp.bottom).offset(4)
            $0.bottom.equalToSuperview()
        }
    }
}

extension TagSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        createRecommendTagTableViewCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57 + 12
    }
    
    private func createRecommendTagTableViewCell(indexPath: IndexPath) -> RecommendTagTableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: RecommendTagTableViewCell.self),
            for: indexPath
        ) as! RecommendTagTableViewCell
        
        return cell
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if flag {
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                animations: {
                    self.view.alpha = 0
                },
                completion: { _ in
                    super.dismiss(animated: false, completion: completion)
                }
            )
        } else {
            super.dismiss(animated: false, completion: completion)
        }
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if flag {
            super.present(viewControllerToPresent, animated: false) {
                self.view.alpha = 0
                UIView.animate(withDuration: 0.15) {
                    self.view.alpha = 1
                } completion: { _ in
                    completion?()
                }
            }
        } else {
            super.present(viewControllerToPresent, animated: false, completion: completion)
        }
    }
}
