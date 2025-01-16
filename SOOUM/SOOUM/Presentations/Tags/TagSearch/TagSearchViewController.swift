//
//  TagSearchViewController.swift
//  SOOUM
//
//  Created by JDeoks on 11/26/24.
//

import UIKit

import ReactorKit
import RxCocoa
import RxGesture
import RxSwift

import SnapKit
import Then

class TagSearchViewController: BaseViewController, View {
    
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
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.items = [space, self.hideKeyboardUIBarButton]
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
                    object.pop()
                }
            }
            .disposed(by: self.disposeBag)
        
        hideKeyboardUIBarButton.rx.tap
            .subscribe(with: self) { object, _ in
                object.view.endEditing(true)
            }
            .disposed(by: self.disposeBag)
    }
    
    func bind(reactor: TagSearchViewReactor) {
        tagSearchTextFieldView.textField.rx.text.orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map {
                Reactor.Action.searchTag($0)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.searchTags)
            .subscribe(with: self) { object, _ in
                object.tableView.reloadData()
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
    
    func pop() {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            animations: {
                self.view.alpha = 0
            },
            completion: { _ in
                self.navigationController?.dismiss(animated: false)
            }
        )
    }
}

extension TagSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reactor = self.reactor else {
            return 0
        }
        return reactor.currentState.searchTags.count
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
        
        guard let reactor = self.reactor else {
            return cell
        }
        if reactor.currentState.searchTags.indices.contains(indexPath.row) {
            cell.setData(searchRelatedTag: reactor.currentState.searchTags[indexPath.row])
            cell.contentView.rx.tapGesture()
                .when(.recognized)
                .subscribe(with: self) { object, _ in
                    let tagID = reactor.currentState.searchTags[indexPath.row].tagId
                    let tagDetailVC = TagDetailViewController()
                    tagDetailVC.reactor = reactor.reactorForTagDetail(tagID)
                    object.navigationController?.pushViewController(tagDetailVC, animated: true)
                }
                .disposed(by: cell.disposeBag)
        }
        return cell
    }
}
