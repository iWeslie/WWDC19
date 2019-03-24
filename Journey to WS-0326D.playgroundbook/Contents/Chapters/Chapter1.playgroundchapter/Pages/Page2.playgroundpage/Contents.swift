/*:

Please scan a vertical wall and place the portal 🚪 on it. You may enter the outer space through it.

* Experiment:
Find a stable vertical wall and scan it slowly until the deploy area is stable. Then press `Deploy` button to open the portal.

- Important:
It is strongly recommended to run the game in a **Full Screen** + **Landscape** mode.

- Note:
If your game crashed, you can transfer it again from AirDrop or rerun it.

[Next Page](@next)
*/

//#-hidden-code
import UIKit
import PlaygroundSupport

let viewController = DeployPortalViewController()

PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code