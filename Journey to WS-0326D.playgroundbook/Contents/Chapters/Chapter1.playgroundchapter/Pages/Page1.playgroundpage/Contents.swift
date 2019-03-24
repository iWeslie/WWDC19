/*:

* Callout(Introduction):
Hey, I'm *Yongkang Chen*, a student from China. It was my enthusiasm that drove me to learn iOS development.\
As we all know, Augmented Reality is the frontier of software development. So I applied `ARKit` Framework to build a cool game.\
🤩 Hope you enjoy it.

- - - 
How about have a space trip with me? I need you to find some ore for me. Earlier today, I have arranged a spaceship 🚀 to pick you up to my space station 🛰 `WS-0326D`. It was located at vector `221.SN-32.0.45-118.46.17`. Your spaceship will send you to my space station. I will meet you there.

👨‍🚀 Auto-pilot protocol initiated...\
🔋 Pulse Engine protocol initiated...\
🛡 Neutrino Shield protocol initiated...\
............

Wake up, pilot. Your spaceship is ready, please **go outside** to call it. 

* Experiment:
Please scan the ground slowly, when you have enough yellow dots, it means that this place is fine for the spaceship to land. 

When you click the `Land` button, walk away immediately and look up. Your spaceship is landing.

- Important:
Make sure you are not in your bedroom, otherwise it will destroy your room.\
It is strongly recommended to run the game in a **Full Screen** + **Landscape** mode.


[Next Page](@next)

*/


//#-hidden-code
import UIKit
import PlaygroundSupport

let viewController = FindYourShipViewController()

PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code