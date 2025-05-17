import UIKit

// MARK: - 菜品模型
struct MenuItem {
    let name: String
    let price: Double
    let description: String
}

// MARK: - 菜品分类模型
struct MenuCategory {
    let name: String
    var items: [MenuItem]
}

class LinkedMenuViewController: UIViewController {
    // MARK: - Properties
    private let leftTableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        table.backgroundColor = .systemGray6
        return table
    }()
    
    private let rightTableView: UITableView = {
        let table = UITableView()
        table.register(MenuItemCell.self, forCellReuseIdentifier: "MenuItemCell")
        table.register(CategoryHeaderView.self, forHeaderFooterViewReuseIdentifier: "CategoryHeaderView")
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        return table
    }()
    
    private var categories: [MenuCategory] = []
    private var selectedCategoryIndex: Int = 0
    private var isScrolling = false
    private var sectionHeaderHeights: [CGFloat] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDummyData()
        setupUI()
        configureTableViews()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // 添加左侧分类列表
        view.addSubview(leftTableView)
        leftTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            leftTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftTableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25)
        ])
        
        // 添加右侧菜品列表
        view.addSubview(rightTableView)
        rightTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightTableView.leadingAnchor.constraint(equalTo: leftTableView.trailingAnchor),
            rightTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rightTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rightTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureTableViews() {
        leftTableView.delegate = self
        leftTableView.dataSource = self
        rightTableView.delegate = self
        rightTableView.dataSource = self
    }
    
    private func setupDummyData() {
        categories = [
            MenuCategory(name: "热销", items: [
                MenuItem(name: "红烧肉", price: 38.0, description: "经典美味"),
                MenuItem(name: "糖醋排骨", price: 42.0, description: "酸甜可口")
            ]),
            MenuCategory(name: "凉菜", items: [
                MenuItem(name: "凉拌黄瓜", price: 12.0, description: "爽口开胃"),
                MenuItem(name: "皮蛋豆腐", price: 16.0, description: "清淡可口")
            ]),
            MenuCategory(name: "主食", items: [
                MenuItem(name: "米饭", price: 2.0, description: "香软可口"),
                MenuItem(name: "馒头", price: 1.5, description: "新鲜出炉")
            ]),
            MenuCategory(name: "饮品", items: [
                MenuItem(name: "雪碧", price: 3.0, description: "心飞扬"),
                MenuItem(name: "可口可乐", price: 3.0, description: "经典可乐"),
                MenuItem(name: "芬达", price: 3.0, description: "新一代的选择！"),
                MenuItem(name: "健力宝", price: 3.0, description: "东方魔水"),
                MenuItem(name: "乌苏啤酒", price: 6.0, description: "碰出好兄弟"),
                MenuItem(name: "RIO", price: 11.0, description: "微醺"),
            ])
        ]
    }
    
    private func scrollToCategory(_ index: Int) {
        var offsetY: CGFloat = 0
        for i in 0..<index {
            offsetY += 40 // 分类标题高度
            offsetY += CGFloat(categories[i].items.count) * 80 // 菜品高度
        }
        rightTableView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension LinkedMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == leftTableView {
            return 1
        } else {
            return categories.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == leftTableView {
            return categories.count
        } else {
            return categories[section].items.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == rightTableView {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CategoryHeaderView") as! CategoryHeaderView
            headerView.titleLabel.text = categories[section].name
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView == rightTableView ? 40 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == leftTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
            cell.textLabel?.text = categories[indexPath.row].name
            cell.backgroundColor = indexPath.row == selectedCategoryIndex ? .systemOrange : .systemGray6
            cell.textLabel?.font = indexPath.row == selectedCategoryIndex ? .boldSystemFont(ofSize: 16) : .systemFont(ofSize: 16)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell
            let item = categories[indexPath.section].items[indexPath.row]
            cell.configure(with: item)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == leftTableView {
            selectedCategoryIndex = indexPath.row
            leftTableView.reloadData()
            scrollToCategory(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == leftTableView {
            return 50
        } else {
            return 80
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == rightTableView else { return }
        
        let offsetY = scrollView.contentOffset.y
        let visibleHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        
        // 处理滚动到顶部和底部的边界情况
        if offsetY <= 0 {
            updateLeftSelection(0)
            return
        } else if offsetY + visibleHeight >= contentHeight {
            updateLeftSelection(categories.count - 1)
            return
        }
        
        // 获取可见的 indexPaths
        guard let visibleIndexPaths = rightTableView.indexPathsForVisibleRows else { return }
        
        // 获取可见的 sections
        _ = Set(visibleIndexPaths.map { $0.section })
        
        // 计算屏幕中心点
        let centerY = offsetY + visibleHeight / 2
        
        // 找到当前在屏幕中心位置的分类
        var currentSection = 0
        var totalHeight: CGFloat = 0
        
        for (index, category) in categories.enumerated() {
            let sectionHeight = 40 + CGFloat(category.items.count) * 80 // header高度 + 所有cell高度
            if centerY >= totalHeight && centerY < totalHeight + sectionHeight {
                currentSection = index
                break
            }
            totalHeight += sectionHeight
        }
        
        updateLeftSelection(currentSection)
    }
    
    private func updateLeftSelection(_ index: Int) {
        guard selectedCategoryIndex != index else { return }
        selectedCategoryIndex = index
        leftTableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .top)
        leftTableView.reloadData()
    }
}

// MARK: - CategoryHeaderView
class CategoryHeaderView: UITableViewHeaderFooterView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: - MenuItemCell
class MenuItemCell: UITableViewCell {
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemRed
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [nameLabel, descriptionLabel, priceLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with item: MenuItem) {
        nameLabel.text = item.name
        descriptionLabel.text = item.description
        priceLabel.text = "¥\(item.price)"
    }
}
