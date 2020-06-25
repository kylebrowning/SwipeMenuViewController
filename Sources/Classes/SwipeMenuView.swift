import UIKit

// MARK: - SwipeMenuViewOptions
public struct SwipeMenuViewOptions {

    public struct TabView {

        public enum Style {
            case flexible
            case segmented
            // TODO: case infinity
        }

        public enum Addition {
            case underline
            case circle
            case none
        }

        public struct ItemView {
            /// ItemView width. Defaults to `100.0`.
            public var width: CGFloat = 100.0

            /// ItemView side margin. Defaults to `5.0`.
            public var margin: CGFloat = 5.0

            /// ItemView font. Defaults to `14 pt as bold SystemFont`.
            public var font: UIFont = UIFont.boldSystemFont(ofSize: 14)

            /// ItemView clipsToBounds. Defaults to `true`.
            public var clipsToBounds: Bool = true

            /// ItemView textColor. Defaults to `.lightGray`.
            public var textColor: UIColor = UIColor(red: 170 / 255, green: 170 / 255, blue: 170 / 255, alpha: 1.0)

            /// ItemView selected textColor. Defaults to `.black`.
            public var selectedTextColor: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }

        public struct AdditionView {
            
            public struct Underline {
                /// Underline height if addition style select `.underline`. Defaults to `2.0`.
                public var height: CGFloat = 2.0
            }
            
            public struct Circle {
                /// Circle cornerRadius if addition style select `.circle`. Defaults to `nil`.
                /// `AdditionView.height / 2` in the case of nil.
                public var cornerRadius: CGFloat? = nil
                
                /// Circle maskedCorners if addition style select `.circle`. Defaults to `nil`.
                /// It helps to make specific corners rounded.
                public var maskedCorners: CACornerMask? = nil
            }

            /// AdditionView side margin. Defaults to `0.0`.
            @available(*, deprecated, message: "Use `SwipeMenuViewOptions.TabView.AdditionView.padding` instead.")
            public var margin: CGFloat = 0.0

            /// AdditionView paddings. Defaults to `.zero`.
            public var padding: UIEdgeInsets = .zero
            
            /// AdditionView backgroundColor. Defaults to `.black`.
            public var backgroundColor: UIColor = .black
            
            /// AdditionView animating duration. Defaults to `0.3`.
            public var animationDuration: Double = 0.3
            
            /// AdditionView swipe animation disable feature. Defaults to 'true'
            public var isAnimationOnSwipeEnable: Bool = true

            /// Underline style options.
            public var underline = Underline()
            
            /// Circle style options.
            public var circle = Circle()
        }

        /// TabView height. Defaults to `44.0`.
        public var height: CGFloat = 44.0

        /// TabView side margin. Defaults to `0.0`.
        public var margin: CGFloat = 0.0

        /// TabView background color. Defaults to `.clear`.
        public var backgroundColor: UIColor = .clear

        /// TabView clipsToBounds. Defaults to `true`.
        public var clipsToBounds: Bool = true

        /// TabView style. Defaults to `.flexible`. Style type has [`.flexible` , `.segmented`].
        public var style: Style = .flexible

        /// TabView addition. Defaults to `.underline`. Addition type has [`.underline`, `.circle`, `.none`].
        public var addition: Addition = .underline

        /// TabView adjust width or not. Defaults to `true`.
        public var needsAdjustItemViewWidth: Bool = true

        /// Convert the text color of ItemView to selected text color by scroll rate of ContentScrollView. Defaults to `true`.
        public var needsConvertTextColorRatio: Bool = true

        /// TabView enable safeAreaLayout. Defaults to `true`.
        public var isSafeAreaEnabled: Bool = true

        /// ItemView options
        public var itemView = ItemView()

        /// AdditionView options
        public var additionView = AdditionView()

        public init() { }
    }

    public struct ContentScrollView {

        /// ContentScrollView backgroundColor. Defaults to `.clear`.
        public var backgroundColor: UIColor = .clear

        /// ContentScrollView clipsToBounds. Defaults to `true`.
        public var clipsToBounds: Bool = true

        /// ContentScrollView scroll enabled. Defaults to `true`.
        public var isScrollEnabled: Bool = true

        /// ContentScrollView enable safeAreaLayout. Defaults to `true`.
        public var isSafeAreaEnabled: Bool = true
    }

    /// TabView and ContentScrollView Enable safeAreaLayout. Defaults to `true`.
    public var isSafeAreaEnabled: Bool = true {
        didSet {
            tabView.isSafeAreaEnabled = isSafeAreaEnabled
            contentScrollView.isSafeAreaEnabled = isSafeAreaEnabled
        }
    }

    /// TabView options
    public var tabView = TabView()

    /// ContentScrollView options
    public var contentScrollView = ContentScrollView()

    public init() { }
}

// MARK: - SwipeMenuViewDelegate

public protocol SwipeMenuViewDelegate: class {

    /// Called before setup self.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int)

    /// Called after setup self.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int)

    /// Called before swiping the page.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int)

    /// Called after swiping the page.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int)
}

extension SwipeMenuViewDelegate {
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) { }
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) { }
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) { }
    public func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) { }
}

// MARK: - SwipeMenuViewDataSource

public protocol SwipeMenuViewDataSource: class {

    /// Return the number of pages in `SwipeMenuView`.
    func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int

    /// Return strings to be displayed at the tab in `SwipeMenuView`.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String

    /// Return a ViewController to be displayed at the page in `SwipeMenuView`.
    func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController

    /// Called to get index of vc.
    func swipeMenuViewGetIndex(vc: UIViewController) -> Int?
}

// MARK: - SwipeMenuView

open class SwipeMenuView: UIView {

    /// An object conforms `SwipeMenuViewDelegate`. Provide views to populate the `SwipeMenuView`.
    open weak var delegate: SwipeMenuViewDelegate?

    /// An object conforms `SwipeMenuViewDataSource`. Provide views and respond to `SwipeMenuView` events.
    open weak var dataSource: SwipeMenuViewDataSource?

    open fileprivate(set) var tabView: TabView? {
        didSet {
            guard let tabView = tabView else { return }
            tabView.dataSource = self
            tabView.tabViewDelegate = self
            addSubview(tabView)
            layout(tabView: tabView)
        }
    }

    lazy var pageViewController: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: [.interPageSpacing: 0])
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.dataSource = self
        vc.delegate = self
        return vc
    }()

    lazy var ruleView: UIView = {
        let view = UIView(frame: .init(x: 0, y: options.tabView.height - 2, width: UIScreen.main.bounds.size.width, height: 2))
        view.backgroundColor = UIColor(red: 0.196, green: 0.196, blue: 0.196, alpha: 1)
        return view
    }()
    let rightGradientView = UILabel()
    let leftGradientView = UILabel()

    public var options: SwipeMenuViewOptions

    fileprivate var isLayoutingSubviews: Bool = false

    fileprivate var pageCount: Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }

    fileprivate var isJumping: Bool = false
    fileprivate var isPortrait: Bool = true

    /// The index of the front page in `SwipeMenuView` (read only).
    open private(set) var currentIndex: Int = 0
    private var jumpingToIndex: Int?

    public init(frame: CGRect, options: SwipeMenuViewOptions? = nil) {

        if let options = options {
            self.options = options
        } else {
            self.options = .init()
        }

        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {

        self.options = .init()

        super.init(coder: aDecoder)
    }

    open override func layoutSubviews() {

        isLayoutingSubviews = true
        super.layoutSubviews()
        if !isJumping {
            reloadData(isOrientationChange: true)
        }
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()

        setup()
    }

    /// Reloads all `SwipeMenuView` item views with the dataSource and refreshes the display.
    public func reloadData(options: SwipeMenuViewOptions? = nil, default defaultIndex: Int? = nil, isOrientationChange: Bool = false) {

        if let options = options {
            self.options = options
        }

        isLayoutingSubviews = isOrientationChange

        if !isLayoutingSubviews {
            reset()
            setup(default: defaultIndex ?? currentIndex)
        }

        jump(to: defaultIndex ?? currentIndex, animated: false)

        isLayoutingSubviews = false
    }

    /// Jump to the selected page.
    public func jump(to index: Int, animated: Bool) {
        guard let tabView = tabView else { return }
        if currentIndex != index {
            delegate?.swipeMenuView(self, willChangeIndexFrom: currentIndex, to: index)
        }
        jumpingToIndex = index

        tabView.jump(to: index)
    }

    public func move(to page: Int) {
        guard let vc = dataSource?.swipeMenuView(self, viewControllerForPageAt: page) else {
            return
        }
        let direction: UIPageViewController.NavigationDirection = page > currentIndex ? .forward : .reverse
        DispatchQueue.main.async { [unowned self] in
            self.pageViewController.setViewControllers([vc], direction: direction, animated: false) { finished in
                //                self.isJumping = false
            }
        }
    }

    /// Notify changing orientaion to `SwipeMenuView` before it.
    public func willChangeOrientation() {
        isLayoutingSubviews = true
        setNeedsLayout()
    }

    fileprivate func update(from fromIndex: Int, to toIndex: Int) {

        if !isLayoutingSubviews {
            delegate?.swipeMenuView(self, willChangeIndexFrom: fromIndex, to: toIndex)
        }

        tabView?.update(toIndex)
        currentIndex = toIndex

        move(to: toIndex)

        isJumping = false
        if !isJumping && !isLayoutingSubviews {
            delegate?.swipeMenuView(self, didChangeIndexFrom: fromIndex, to: toIndex)
        }
    }

    // MARK: - Setup
    private func setup(default defaultIndex: Int = 0) {

        delegate?.swipeMenuView(self, viewWillSetupAt: defaultIndex)

        backgroundColor = .clear

        tabView = TabView(frame: CGRect(x: 0, y: 0, width: frame.width, height: options.tabView.height), options: options.tabView)
        tabView?.clipsToBounds = options.tabView.clipsToBounds

        translatesAutoresizingMaskIntoConstraints = false
        pageViewController.scrollView?.delegate = self

        pageViewController.view.frame = CGRect(x: 0, y: options.tabView.height, width: frame.width, height: frame.height - options.tabView.height)
        viewController?.addChild(pageViewController)
        addSubview(pageViewController.view)
        layout(pageViewController: pageViewController)
        pageViewController.didMove(toParent: viewController)
        tabView?.update(defaultIndex)
        move(to: defaultIndex)
        currentIndex = defaultIndex

        delegate?.swipeMenuView(self, viewDidSetupAt: defaultIndex)
        setupGradientViews()
        addSubview(ruleView)
        sendSubviewToBack(ruleView)
    }

    func setupGradientView(_ view: UILabel) {
        view.backgroundColor = .clear
        let width = UIScreen.main.bounds.width

        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.8).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
        switch view {
            case leftGradientView:
                view.frame = CGRect(x: 0, y: 0, width: 45, height: 44)
            case rightGradientView:
                view.frame = CGRect(x: width - 45, y: 0, width: 45, height: 44)
                layer.transform = CATransform3DMakeScale(-1, 1, 1)
            default:
                preconditionFailure("Attemping to setup a gradient whos frame will not be set.")
        }

        layer.bounds = view.bounds
        layer.position = view.center
        view.layer.addSublayer(layer)
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    func setupGradientViews() {
        setupGradientView(rightGradientView)
        setupGradientView(leftGradientView)
        rightGradientView.isHidden = false
        leftGradientView.isHidden = true
    }

    private func layout(tabView: TabView) {

        tabView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: self.topAnchor),
            tabView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tabView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tabView.heightAnchor.constraint(equalToConstant: options.tabView.height)
        ])
    }

    private func layout(contentScrollView: ContentScrollView) {

        contentScrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: options.tabView.height),
            contentScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    private func layout(pageViewController: UIPageViewController) {
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: self.topAnchor, constant: options.tabView.height),
            pageViewController.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 44)
        ])
    }

    private func reset() {

        if !isLayoutingSubviews {
            currentIndex = 0
        }

        if let tabView = tabView {
            tabView.removeFromSuperview()
            tabView.reset()
        }
    }
}

// MARK: - TabViewDelegate, TabViewDataSource

extension SwipeMenuView: TabViewDelegate, TabViewDataSource {
    public func tabViewDidScroll(_ tabView: TabView) {
        let contentOffset = tabView.contentOffset
        let contentSize = tabView.contentSize
        let width = UIScreen.main.bounds.width
        if contentOffset.x > 1.0 && (contentSize.width - contentOffset.x) > width + 20 {
            rightGradientView.isHidden = false
            leftGradientView.isHidden = false
        } else if contentOffset.x <= 0.0 {
            rightGradientView.isHidden = false
            leftGradientView.isHidden = true
        } else {
            rightGradientView.isHidden = true
            leftGradientView.isHidden = false
        }
        print("\(contentOffset) \((contentSize.width - contentOffset.x)) >= \(width)")
    }


    public func tabView(_ tabView: TabView, didSelectTabAt index: Int) {

        guard currentIndex != index else {
            return
        }

        isJumping = true
        jumpingToIndex = index

        update(from: currentIndex, to: index)
    }

    public func numberOfItems(in menuView: TabView) -> Int {
        return dataSource?.numberOfPages(in: self) ?? 0
    }

    public func tabView(_ tabView: TabView, titleForItemAt index: Int) -> String? {
        return dataSource?.swipeMenuView(self, titleForPageAt: index)
    }
}

// MARK: - UIScrollViewDelegate

extension SwipeMenuView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isJumping || isLayoutingSubviews {
            print("skipped")
            return
        }

        updateTabViewAddition(by: scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateTabViewAddition(by: scrollView)
    }

    /// update addition in tab view
    private func updateTabViewAddition(by scrollView: UIScrollView) {
        moveAdditionView(scrollView: scrollView)
    }

    /// update underbar position
    private func moveAdditionView(scrollView: UIScrollView) {
        if let tabView = tabView {
            let point = scrollView.contentOffset
            let view = pageViewController.view!
            let ratioForward: CGFloat = abs(point.x - view.frame.size.width) / view.frame.size.width
            let ratioBack: CGFloat = 1 - ratioForward
            guard let jumpingToIndex = jumpingToIndex else {
                return
            }
            if jumpingToIndex > currentIndex {
                tabView.moveAdditionView(index: currentIndex, ratio: ratioForward, direction: .forward)
            } else {
                tabView.moveAdditionView(index: currentIndex, ratio: ratioBack, direction: .reverse)
            }
        }
    }
}


extension SwipeMenuView: UIPageViewControllerDataSource {

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if currentIndex <= 0 {
            return nil
        }
        return dataSource?.swipeMenuView(self, viewControllerForPageAt: currentIndex - 1)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentIndex + 1 >= pageCount {
            return nil
        }
        let vc = dataSource?.swipeMenuView(self, viewControllerForPageAt: currentIndex + 1)
        return vc
    }
}

extension SwipeMenuView: UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {

        guard let datasource = dataSource,
              let toVC = pendingViewControllers.first,
              let index = datasource.swipeMenuViewGetIndex(vc: toVC)
        else { return }
        jumpingToIndex = index
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else {
            return
        }
        if let toIndex = jumpingToIndex {
            delegate?.swipeMenuView(self, didChangeIndexFrom: currentIndex, to: toIndex)
            currentIndex = toIndex
            jumpingToIndex = nil
            isJumping = false
        }
    }
}


extension UIPageViewController {

    var scrollView: UIScrollView? {
        return self.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
    }
}

extension UIView {
    var viewController: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let responder = responder as? UIViewController {
                return responder
            }
            responder = responder?.next
        }
        return nil
    }
}
