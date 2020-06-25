import UIKit
import SwipeMenuViewController

final class ViewController: SwipeMenuViewController {

    private var datas: [String] = ["Bulbasaur","Caterpie", "Golem", "Jynx", "Marshtomp", "Salamence", "Riolu", "Araquanid", "Pickachu", "Another"]

    var options = SwipeMenuViewOptions()
    var dataCount: Int = 9
    var vcs: [ContentViewController] = []
    @IBOutlet private weak var settingButton: UIButton!

    override func viewDidLoad() {

        for n in 0...dataCount {
            let vc = ContentViewController()
            vc.title = datas[n]
            vc.content = datas[n]
            vcs.append(vc)
        }
//        view.bringSubviewToFront(settingButton)
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popupSegue" {
            let vc = segue.destination as! PopupViewController
            vc.options = options
            vc.dataCount = dataCount
            vc.reloadClosure = { self.reload() }
        }
    }

    private func reload() {
        swipeMenuView.reloadData(options: options)
    }

    // MARK - SwipeMenuViewDataSource

    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return dataCount
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return vcs[index].title ?? ""
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        return vcs[index]
    }

    override func swipeMenuViewGetIndex(vc: UIViewController) -> Int? {
        guard let vc = vc as? ContentViewController else { return nil }
        return vcs.firstIndex(of: vc)
    }
}
