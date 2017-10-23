## Framer Vertical Panel
[![license](https://img.shields.io/github/license/bpxl-labs/RemoteLayer.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](.github/CONTRIBUTING.md)
[![Maintenance](https://img.shields.io/maintenance/yes/2017.svg)]()

Framer Vertical Panel is a component inspired on the bottom sheet view pattern of Maps (iOS) by Apple. [View demo](https://framer.cloud/WNLzV)

[![verticalpanel.png](https://s1.postimg.org/75635n4agv/verticalpanel.png)](https://postimg.org/image/2ikg4y5qt7/)


### Install with Framer Modules

<a href='https://open.framermodules.com/Vertical Panel'>
    <img alt='Install with Framer Modules'
    src='https://www.framermodules.com/assets/badge@2x.png' width='160' height='40' />
</a>

### Manual Install

1. Copy the `verticalPanelComponent.coffee` file in the modules directory inside your project.

2. Import it using this line one the top of your code view   
`VerticalPanel = require 'verticalPanelComponent'`

3. Create your first vertical panel using  
`panelBuilder = new VerticalPanel`

### Default States

Each vertical panel has 4 default states. You can overwrite them by passing a numeric value. This number is the percentage of the screen that the panel will cover. For example, setting `middle: 50` make the panel cover half of the screen.

| State name |   Property   | Default value | Description                    |
| :--------: | :----------: | :-----------: | ------------------------------ |
|   hidden   |              |       0       | Use this to hide the component |
|   bottom   | bottom |      10       | Show panel at 10% of the screen height  |
|   middle   | middle |      45       | Show panel at 45% of the screen height  |
|    top     |  top  |      90       | Show panel at 90% of the screen height  |


### Customization styles and animations

|    Property    | Default Value | Description                              |
| :------------: | :-----------: | ---------------------------------------- |
|   alphaColor   |    #000000    | Color of alpha that appear when moving between `middle` and `top` states. |
|   alphaOpacity |    0.6        | Opacity value for the alpha background |
| backgrounColor |    #F0F0F0    | Background color of the panel            |
|     image      |               | Background image of the panel            |
|   initState    |    hidden     | State in which the panel will be initialized |
|      name      | verticalPanel | Name that will have the layers created, this helps to identify the panel in your list of layers. |
|      indicator | true          | Show the indicator on the top of the panel |
|      dragable  | true          | Set the panel to be dragable |
| animationCurve | Bezier(0.645,0.045,0.355,1) | Curve to when panel move between states |
| speedRatio     | 0.875           | Higher the number, faster the animations. * |

\* The animations between states now have a variable timing relative to the distance (points) to move. For example if the panel will animate 300 points, the calc will be `Utils.round(300 / speedRatio) / 1000` = `0.343` seconds.

You can always use `panelName.content.animate('stateName', options)` if you want have more control.

### Functions

| Function          | Description          |
| ----------------- | -------------------- |
| panelName.wrapper | Returns the wrapper layer. This layer contains everything, including the alpha background |
| panelName.content | Returns the panel layer. This helps change layers properties, add new states, etc. |
| panelName.indicator | Return the indicator layer. |
| panelName.state | Returns current panel state. For example 'top', 'middle' |
| panelName.animateTo | Gets the difference on position Y between current state and next one, then animate based on the speedRatio property. |

### Examples

```coffeescript
# Create a panel, initialize it with the 'bottom' state, and a red background
panelBuilder = new VerticalPanel
  name: 'builder'
  initState: 'bottom'
  backgroundColor: 'red'
  speedRatio: 600

# Change panel properties after it has been created
panelBuilder.content.backgrondColor = 'cyan'
panelBuilder.content.blur = 3

# Print the current panel state name
print panelBuilder.state

# Set a custom name and overwrite the default state heights, and add an image as background
panelVehicle = new VerticalPanel
  name: 'myVehiclesPanel'
  bottom: 5
  middle: 30
  top: 50
  image: 'images/vehicles.png'

# Animate to other state
panelBuilder.animateTo('top')

# Animate to other state with default .animate function
panelBuilder.content.animate(
	'top',
    options: time: 1, curve: Spring(damping: 0.1)
)

# Add a new state to the panel and animate
panel.content.states.bgPurple =
  backgroundColor: 'purple'
  options: time: 0.5

panel.content.animate('bgPurple')
```
