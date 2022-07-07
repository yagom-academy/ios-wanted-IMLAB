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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.update {
            self.tableView.reloadData()
        }
    }

    private func attribute() {
        title = "Voice Memos"
        view.backgroundColor = YagomColor.one.uiColor

        AddNavigationbarRightItem()

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

    private func AddNavigationbarRightItem() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentRecordPage))
        navigationItem.rightBarButtonItems = [addButton]
    }

    @objc private func presentRecordPage() {
        let vc = RecordViewController()
        navigationController?.pushViewController(vc, animated: true)
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

// MARK: - UITableViewDataSource, UITableViewDelegate 메서드

extension RecordListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCellTotalCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecordListCell.identifier, for: indexPath) as? RecordListCell else {
            return UITableViewCell()
        }
        
        cell.setData(data: viewModel.getCellData(indexPath), indexPath: indexPath)
        cell.addSwapCellTapGesture(action: handleLongPress(with:_:))
        cell.addFavoriteMarkAction(action: handleFavoriteButton(indexPath:))
        
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
        let data = viewModel.getCellData(indexPath)
        let vc = PlayerViewController()

        vc.setData(data.fileInfo.rawFilename)

        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - 테이블뷰를 당겼을 때 새로고침시키는 메서드

extension RecordListViewController {
    private func setRefresh() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }

    @objc private func didPullToRefresh() {
        viewModel.update(completion: {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        })
    }
}

//MARK: - 셀정렬버튼
extension RecordListViewController: RecordListSortBarDelegate {
    func sortButtonTapped(sortState: RecordListSortState) {
        switch sortState {
        case .latest:
            print("최신순 버튼 클릭!")
        case .oldest:
            print("오래된순 버튼 클릭!")
        }
    }
}

//MARK: - 즐겨찾기 버튼 이벤트
extension RecordListViewController {
    private func handleFavoriteButton(indexPath: IndexPath) {
        viewModel.tappedFavoriteButton(indexPath: indexPath)
        self.tableView.reloadData()
    }
}

//MARK: - 셀이동 이벤트
extension RecordListViewController {
    private func handleLongPress(with sender: UILongPressGestureRecognizer, _ toCenterPoint: CGPoint) {
        swapByPress(with: sender, toCenterPoint: toCenterPoint)
    }

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
            viewModel.endSwapCellTapped()
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
            viewModel.endSwapCellTapped()
            // 손가락을 떼면 indexPath에 셀이 나타나는 애니메이션
            guard let beforeIndexPath = BeforeIndexPath.value,
                  let cell = tableView.cellForRow(at: beforeIndexPath) else { return }
            cell.isHidden = false
            cell.alpha = 0.0

            // Snapshot이 사라지고 셀이 나타내는 애니메이션 부여
            UIView.animate(withDuration: 0.3) {
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
