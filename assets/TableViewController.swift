//
//  TableViewController.swift
//  ToySwiftNetworking
//
//  Created by makuvex7 on 2022/07/05.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Toast

extension ConstraintMakerRelatable {
    @discardableResult
    public func equalToSafeAreaAuto(_ view: UIView, _ file: String = #file, _ line: UInt = #line) -> ConstraintMakerEditable {
        if #available(iOS 11.0, *) {
            return self.equalTo(view.safeAreaLayoutGuide, file, line)
        }
        return self.equalToSuperview()
    }
}

final class TableViewController: UIViewController {
    let button = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("이거슨 버튼", for: .normal)
        $0.backgroundColor = .magenta
    }

    let tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .systemBackground
        $0.estimatedRowHeight = 100
        $0.rowHeight = UITableView.automaticDimension
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private let disposeBag = DisposeBag()
    private let networkingRelay: PublishRelay<Void> = PublishRelay<Void>()
    private let updateTextViewRelay: PublishRelay<Result<HttpBinModel, Error>> = PublishRelay<Result<HttpBinModel, Error>>()
    
    var tableViewDataArray: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        //setupTableView()
        bindRxUI()
    }
}

extension TableViewController {
    func setupLayout() {
        self.view.addSubview(button)
        self.view.addSubview(tableView)
        
        button.snp.makeConstraints {
            $0.top.leading.trailing.equalToSafeAreaAuto(self.view)
            $0.height.equalTo(70)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.button.snp.bottom)
            $0.leading.trailing.bottom.equalToSafeAreaAuto(self.view)
        }
    }
    
    func bindRxUI() {
        /// 버튼을 누르면 토스트를 출력하고 네트워킹 api를 호출 한다.
        /// api 결과를 받아서 테이블 뷰에 출력
        /// 테이블뷰 셀을 선택 하면 indexPath의 row를 전달하여 토스트를 출력
        /// 그리고 스크롤을 맨위로 올린다.
        
        /// 1. 버튼을 누르면 토스트를 출력하고 네트워킹 api를 호출 한다.
        button.rx.tap
            .do(onNext: { [weak self] _ in
                self?.view.makeToast("API 호출")
            })
            .bind(to: networkingRelay)
            .disposed(by: disposeBag)

        networkingRelay
            .asObservable()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .concatMap { _ -> Observable<Result<HttpBinModel, Error>> in
                let request = TestGetRequest(requestData: AuthRequestConfiguration(acceptCountry: "kr"), parameters: ["args" : "queryItemsTest"])
                return AFBoltApiClient.requestObservable(request: request).asObservable()
            }
            .bind(to: updateTextViewRelay)
            .disposed(by: disposeBag)

        /// 2. api 결과를 받아서 테이블 뷰에 출력
        updateTextViewRelay
            .asObservable()
            .map { result -> [String] in
                switch result {
                case .success(let dataModel):
                    guard let dictionary = dataModel.debugPrettyDescription.convertToDictionary() else { return [] }
                    return dictionary.map { "\($0.key) \($0.value)" }
                case .failure(let error):
                    return [error.localizedDescription]
                }
            }
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items) { (tableView, row, item) -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
                    return UITableViewCell()
                }
                cell.textLabel?.text = "\(item)"
                return cell
            }
            .disposed(by: disposeBag)
        
        /// 3. 테이블뷰 셀을 선택 하면 indexPath의 row를 전달하여 토스트를 출력
        /// 4. 그리고 스크롤을 맨위로 올린다.
        tableView.rx.itemSelected
            .map { [weak self] indexPath -> Void in
                self?.view.makeToast("indexPath row : \(indexPath.row)")
                return
            }
            .subscribe(onNext: scrollToTop)
            .disposed(by: disposeBag)
    }
    
    func scrollToTop() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

extension TableViewController {
    func setupTableView() {
        /// delegate와 selector지정
        tableView.delegate = self
        tableView.dataSource = self
        
        button.addTarget(self, action: #selector(clickedButton), for: .touchUpInside)
    }
    
    @objc func clickedButton(_ sender: Any?) {
        /// 1. 버튼을 누르면 토스트를 출력하고 네트워킹 api를 호출 한다.
        self.view.makeToast("API 호출")
        
        /// 2. api 결과를 받아서 테이블 뷰에 출력
        DispatchQueue.global().async {
            let request = TestGetRequest(requestData: AuthRequestConfiguration(acceptCountry: "kr"), parameters: ["args" : "queryItemsTest"])
            AFSessionBoltApiClient.shared.request(request: request) { [weak self] results in
                guard let `self` = self else { return }
                
                switch results {
                case .success(let dataModel):
                    guard let dictionary = dataModel.debugPrettyDescription.convertToDictionary() else {
                        self.tableViewDataArray = []
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }

                        return
                    }
                    self.tableViewDataArray = dictionary.map { "\($0.key) \($0.value)" }
                case .failure(let error):
                    self.tableViewDataArray = [error.localizedDescription]
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
            return UITableViewCell()
        }
        cell.textLabel?.text = tableViewDataArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// 3. 테이블뷰 셀을 선택 하면 indexPath의 row를 전달하여 토스트를 출력
        self.view.makeToast("indexPath row : \(indexPath.row)")

        /// 4. 그리고 스크롤을 맨위로 올린다.
        scrollToTop()
    }
}
