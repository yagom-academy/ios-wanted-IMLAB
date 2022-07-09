//
//  RecordListVeiwController.swift
//  VoiceRecorder
//
//  Created by 김기림 on 2022/06/29.
//

import UIKit

class RecordListViewController: UIViewController {
    private let containerStackView = UIStackView()
    private let sortBar = RecordListSortBar()
    private let tableView = UITableView()
    private let viewModel = RecordListViewModel(networkManager:  RecordNetworkManager.shared)
    
    struct Math {
        static let sortBarHeightMultiplier: Double = 0.05
        static let tableViewHeightMultiplier: Double = 0.9
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        attribute()
        layout()
        setRefresh()
        AddNavigationbarRightItem()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTableViewCell()
    }
}

//MARK: - attribute, layout 메서드
extension RecordListViewController {
    private func attribute() {
        title = "녹음파일 리스트"
        view.backgroundColor = ThemeColor.blue100

        containerStackView.axis = .vertical
        containerStackView.distribution = .equalSpacing

        sortBar.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecordListCell.self, forCellReuseIdentifier: RecordListCell.identifier)

        tableView.separatorInset.left = 0

        tableView.reloadData()
        tableView.backgroundColor = .clear
    }

    private func layout() {
        self.view.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        containerStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        containerStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        containerStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        let topPadding = UIView()
        topPadding.backgroundColor = .red

        [topPadding, sortBar, tableView].forEach {
            containerStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        topPadding.heightAnchor.constraint(equalToConstant: 0).isActive = true
        sortBar.heightAnchor.constraint(equalTo: containerStackView.heightAnchor, multiplier: Math.sortBarHeightMultiplier).isActive = true
        tableView.heightAnchor.constraint(equalTo: containerStackView.heightAnchor, multiplier: Math.tableViewHeightMultiplier).isActive = true
    }
}

// MARK: - UITableView DataSource, Delegate 메서드
extension RecordListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return viewModel.getCellTotalCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecordListCell.identifier, for: indexPath)  as? RecordListCell,
              let data = viewModel.getCellData(indexPath) else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        cell.setData(data: data, indexPath: indexPath)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteCell(indexPath) {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = viewModel.getCellData(indexPath) else {
            return
        }
        let vc = PlayerViewController()
        vc.setData(data.fileInfo)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - RecordListCell(셀) Delegate 메서드
extension RecordListViewController: RecordListCellDelegate {
    func tappedFavoriteMark(_ indexPath: IndexPath) {
        viewModel.tappedFavoriteButton(indexPath: indexPath)
        tableView.reloadData()
        sortBar.viewWillAppear()
    }
    
    func beginSwapCellLongTapGesture(_ sender: UILongPressGestureRecognizer, _ toCenterPoint: CGPoint) {
        swapByPress(with: sender, toCenterPoint: toCenterPoint)
    }
}


// MARK: - 오른쪽 네비게이션아이템 추가하는 메서드
extension RecordListViewController {
    private func AddNavigationbarRightItem() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentRecordPage))
        navigationItem.rightBarButtonItems = [addButton]
    }

    @objc private func presentRecordPage() {
        let vc = RecordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 셀데이터를 새로고침시키는 메서드(+테이블뷰를 당겼을 때)
extension RecordListViewController {
    private func setRefresh() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshTableViewCell), for: .valueChanged)
    }

    @objc private func refreshTableViewCell() {
        viewModel.update(completion: { result in
            switch result {
            case .success():
                self.tableView.reloadData()
                self.sortBar.viewWillAppear()
                self.tableView.refreshControl?.endRefreshing()
            case .failure(let error):
                let alert = UIAlertController(title: "", message: error.description, preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            }
        })
    }
}

//MARK: - 셀정렬버튼 이벤트 메서드
extension RecordListViewController: RecordListSortBarDelegate {
    func sortButtonTapped(sortState: RecordListSortState) {
        viewModel.sortButtonTapped(beforeState: sortBar.sortState, afterState: sortState, completion: { [weak self] in
            self?.tableView.reloadData()
        })
    }
}

//MARK: - 셀이동 이벤트
extension RecordListViewController {
    func swapByPress(with sender: UILongPressGestureRecognizer, toCenterPoint: CGPoint) {
        let tableViewWidth: CGFloat = tableView.contentSize.width
        let tableViewHeight: CGFloat = tableView.contentSize.height
        var longPressedPoint = sender.location(in: tableView)

        longPressedPoint.x = longPressedPoint.x <= 1 ? 1 : longPressedPoint.x
        longPressedPoint.x = longPressedPoint.x >= tableViewWidth - 1 ? tableViewWidth - 1 : longPressedPoint.x
        longPressedPoint.y = longPressedPoint.y <= 1 ? 1 : longPressedPoint.y
        longPressedPoint.y = longPressedPoint.y >= tableViewHeight - 1 ? tableViewHeight - 1 : longPressedPoint.y

        guard let indexPath = tableView.indexPathForRow(at: longPressedPoint) else {
            print("fail to find indexPath!")
            return
        }

        longPressedPoint.x -= ToCenterPoint.value?.x ?? 0.0
        longPressedPoint.y += ToCenterPoint.value?.y ?? 0.0

        struct ToCenterPoint {
            static var value: CGPoint?
        }

        struct BeforeIndexPath {
            static var value: IndexPath?
        }

        struct CellSnapshotView {
            static var value: UIView?
        }

        switch sender.state {
        case .began:
            BeforeIndexPath.value = indexPath

            ToCenterPoint.value = CGPoint(x: toCenterPoint.x, y: toCenterPoint.y)
            longPressedPoint.x -= ToCenterPoint.value?.x ?? 0.0
            longPressedPoint.y += ToCenterPoint.value?.y ?? 0.0
            // snapshot을 tableView에 추가
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            CellSnapshotView.value = cell.contentView.snapshotCellStyle()
            CellSnapshotView.value?.center = cell.center
            CellSnapshotView.value?.alpha = 0.0
            if let cellSnapshotView = CellSnapshotView.value {
                tableView.addSubview(cellSnapshotView)
            }

            // 원래의 cell을 hidden시키고 snapshot이 보이도록 설정
            UIView.animate(withDuration: 0.3) {
                CellSnapshotView.value?.center = longPressedPoint
                CellSnapshotView.value?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                CellSnapshotView.value?.alpha = 0.98
                cell.alpha = 0.0
            } completion: { isFinish in
                if isFinish {
                    cell.isHidden = true
                }
            }
        case .changed:
            CellSnapshotView.value?.center = longPressedPoint

            if let beforeIndexPath = BeforeIndexPath.value, beforeIndexPath != indexPath {
                viewModel.swapCell(beforeIndexPath.row, indexPath.row)
                tableView.moveRow(at: beforeIndexPath, to: indexPath)

                BeforeIndexPath.value = indexPath
            }
        case .ended:
            if (sortBar.sortState != .favorite) {
                viewModel.endSwapCellTapped()
                sortBar.cellChanged()
            }
            // 손가락을 떼면 indexPath에 셀이 나타나는 애니메이션
            guard let beforeIndexPath = BeforeIndexPath.value,
                  let cell = tableView.cellForRow(at: beforeIndexPath) else { return }
            cell.isHidden = false
            cell.alpha = 0.0
            
            // 더블클릭, 오른쪽으로 끌어당겼을 때 Snapshot이 사라지는 버그방지
            UIView.animate(withDuration: 0) {
                CellSnapshotView.value?.center = cell.center
                CellSnapshotView.value?.transform = CGAffineTransform.identity
                CellSnapshotView.value?.alpha = 1.0
                cell.alpha = 1.0
            } completion: { isFinish in
                if isFinish {
                    BeforeIndexPath.value = nil
                    CellSnapshotView.value?.removeFromSuperview()
                    CellSnapshotView.value = nil
                    ToCenterPoint.value = nil
                }
            }
        default:
            break
        }
    }
}
