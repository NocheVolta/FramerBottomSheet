## Framer Vertical Panel

Framer Vertical Panel is a component based on the bottom sheet view implementation found in Maps by Apple. 

### Setup

1. Copy the `verticalPanelComponent.coffee` file in the modules directory inside your project.

2. Import it using this line one the top of your code view   
`VerticalPanel = require "verticalPanelComponent"`

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

### Functions

| Function          | Description          |
| ----------------- | -------------------- |
| panelName.content | Returns the panel layer. This helps change layers properties, add new states, etc. |
| panelName.indicator | Return the indicator layer. |
| panelName.state | Returns current panel state. For example 'top', 'middle' |
| panelName.animateTo | Gets the difference on position Y between current state and next one, then animate based on the speedRatio property. |


### Customisation

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
| speedRatio     | 875           | Higher the number, faster the animations. * |

\* The animations between states now have a variable timming depeding the distance (points) to move. For example if the panel will animate 300 points, the calc will be `Utils.round(300 / speedRatio, 3)` = `0.343` seconds. 


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
panelBuilder = new VerticalPanel
print panelBuilder.state

# Overwrite the default state heights, and add an image as background
panelVehicle = new VerticalPanel
  name: 'vehicleSelector'
  bottom: 5
  middle: 30
  top: 50
  image: 'images/vehicles.png'

# Animate to other state
panelBuilder.animateTo('top')

# Add a new state to the panel
panelVehicle.content.states.slideRight =
  x: Screen.width

panelVehicle.content.animate('slideRight')
```
