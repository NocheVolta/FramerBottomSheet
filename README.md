## Framer Bottom Sheet
[![license](https://img.shields.io/github/license/bpxl-labs/RemoteLayer.svg)](https://opensource.org/licenses/MIT)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)
![Maintenance](https://img.shields.io/maintenance/yes/2018.svg)

Framer Bottom Sheet is a component inspired on the bottom sheet view pattern of Maps (iOS) by Apple. 
[View demo](https://framer.cloud/nDHim)

<img src="https://raw.githubusercontent.com/NocheVolta/FramerBottomSheet/master/bottomSheet.gif" width="320"/>

### Install with Framer Modules

<a href='https://open.framermodules.com/Bottom Sheet'>
  <img alt='Install with Framer Modules'
  src='https://www.framermodules.com/assets/badge@2x.png' width='160' height='40' />
</a>

### Manual Install

1. Copy the `BottomSheet.coffee` file in the modules directory inside your project.

2. Import it using this line one the top of your code view   
`BottomSheet = require 'BottomSheet'`

3. Create your first bottom sheet using
`bottomSheet = new BottomSheet`

### Customization styles and animations

|    Property    | Default Value | Description                              |
| :------------: | :-----------: | ---------------------------------------- |
|   alphaColor   |    '#000000'    | Color of alpha that appear when moving to the highest state. |
|   alphaOpacity |    0.6        | Opacity value for the alpha background |
| animationCurve | Spring(damping: 0.75) | Curve to when sheet move between states |
| backgrounColor |    '#F0F0F0'    | Background color of the sheet            |
| deltaTolerance | 1.25           |  Minium number of delta movement to move sheet to the highest/lowest state |
|      dragable  | true          | Define if sheet is dragable |
| fallbackState  |              | State to be used when a previous state is not available and user tap on the dim background.  |
| hideable      | true           |  Define is sheet can be dismissed |
|     image      |               | Background image of the sheet            |
|      indicator | true          | Show the indicator on the top of the sheet |
|   initState    |               | State in which the sheet will be initialized |
|      name      | 'verticalPanel' | Name that will have the layers created, this helps to identify the sheet in your list of layers. |
| speedRatio     | 0.35         | Higher the number, faster the animations |
| states      | 30              | Read about define custom states  |
| tolerance      | 30           | Minimum number of points of tolerance on DragEnd to come back to the current state.  |

You can always use `bottomSheet.content.animate('stateName', options)` if you want have more control.

### Default states

Each bottom sheet has 3 default states.

| Defaut state name |   Property   | Default value | Description                    |
| :---------------: | :----------: | :-----------: | ------------------------------ |
|   bottom          | bottom       |      15       | Show sheet at 15% of the screen height  |
|   middle          | middle       |      45       | Show sheet at 45% of the screen height  |
|    top            |  top         |      90       | Show sheet at 90% of the screen height  |

### Define custom states

You can define your custom states by passing an array. The `height` value is the % of the `Screen.height`. For example `50` means the half of the screen.  

```coffeescript
bottomSheet = new BottomSheet
  states: [
    { name: 'small', height: 15 }
    { name: 'midium', height: 40 }
    { name: 'big', height: 75 }
    { name: 'full', height: 100 }
  ]
```

### Functions

| Function          | Description          |
| ----------------- | -------------------- |
| bottomSheet.wrapper | Returns the wrapper layer. This layer contains everything, including the alpha background |
| bottomSheet.content | Returns the sheet layer. This helps change layers properties, add new states, etc. |
| bottomSheet.indicator | Return the indicator layer. |
| bottomSheet.state | Returns current sheet state. For example 'top', 'middle' |
| bottomSheet.animateTo(state, time) | Gets the difference on position Y between current state and next one, then animate based on the speedRatio property, time argument overwrite the speedRatio and max/min values. |

### Examples

```coffeescript
# Create a sheet, initialize it with the 'bottom' state, and a red background
bottomSheet = new BottomSheet
  name: 'builder'
  initState: 'bottom'
  backgroundColor: 'red'

# Change sheet properties after it has been created
bottomSheet.content.backgrondColor = 'cyan'
bottomSheet.content.blur = 3

# Print the current sheet state name
print bottomSheet.state

# Set a custom name and overwrite the default state heights, and add an image as background
panelVehicle = new BottomSheet
  name: 'myVehiclesPanel'
  image: 'images/vehicles.png'

# Animate to other state
bottomSheet.animateTo('top', 0.75)

# Animate to other state with default .animate function
bottomSheet.content.animate(
  'top',
  options: time: 1, curve: Spring(damping: 0.1)
)

# Add a new state to the sheet and animate
sheet.content.states.bgPurple =
  backgroundColor: 'purple'
  options: time: 0.5

bottomSheet.content.animate('bgPurple')
```
