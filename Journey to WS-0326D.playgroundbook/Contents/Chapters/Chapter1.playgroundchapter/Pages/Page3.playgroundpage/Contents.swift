/*:

- - -
`SYSTEM ERROR`

`Exit code address: 0x8badf00d...`

`[Client] Local error: UserInfo={$(cannot load)}`

`Symbol not found...`
- - - 
\> Scanning......

\> Auto-pilot offline... 

\> Switch to manual mode...

\> Detected electromagnetic pulse...

You are now passing through asteroid belt...

Be careful pilot, it’s **dangerous** in the `asteroid belt`.

* Experiment:
The last portal disappeared. Please scan the stable wall again. When the portal is stable, tap to enter it. Now mind the stone!

These are the objects you will encounter in `asteroid belt`.
### Stones: 
![stones](preview_stones.jpg)

### Coins:
![coin](preview_coin.jpg)

### Diamonds:
![diamond](preview_diamond.jpg)

* Note:
Stones    +1 speed: `Random`\
Coins     +10 speed: `Faster`\
Diamonds +50 speed: `Rapid`

- Important:
It is strongly recommended to run the game in a **Full Screen** + **Landscape** mode.

You will meet different kinds of meteorite, they contain coins and rare diamonds. Collect the coins and diamonds as much as you can. 

Tap the screen to shoot them. Don’t let the stone hit your spaceship.

*/


//#-hidden-code
import UIKit
import PlaygroundSupport

let viewController = SpaceTravelViewController()

PlaygroundPage.current.liveView = viewController
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code