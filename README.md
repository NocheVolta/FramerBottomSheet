## Framer Vertical Panel

Component insipirated on a simple pattern used on many apps, like Maps by Apple or Google Maps. 

### Setup

1. Copy the `verticalPanelComponent.coffee` file in the modules folder inside your project.

2. Import it using this line one the top of your code view   
`VerticalPanel = require "verticalPanelComponent"`

3. Create it your first vertical panel using  
`panelBuilder = new VerticalPanel`

### Default States

Each vertial panel you have 4 default states, you can overwrite them passing a number, this number is the percentage of the screen that the panel will cover. For example, set `middleHeight: 50` will cover the half of the screen with the panel.

| State name |   Property   | Default value | Description                    |
| :--------: | :----------: | :-----------: | ------------------------------ |
|   hidden   |              |       0       | Use this to hide the component |
|   bottom   | bottom |      10       | Show panel at 10% of the screen height  |
|   middle   | middle |      45       | Show panel at 45% of the screen height  |
|    top     |  top  |      90       | Show panel at 90% of the screen height  |

### Functions

| Function          | Description          |
| ----------------- | -------------------- |
| panelName.content | Get the panel layer. This helps to change layers properties, add new states, etc. |

### Customisation

|    Property    | Default Value | Description                              |
| :------------: | :-----------: | ---------------------------------------- |
|   alphaColor   |    #000000    | Color of alpha that appear when moving between `middle` and `top` states. |
| backgrounColor |    #F0F0F0    | Background color of the panel            |
|     image      |               | Background image of the panel            |
|   initState    |    hidden     | State in wich the panel will be initialized |
|      name      | verticalPanel | Name that will have the layers created, this helps to identify the panel in your list of layers. |

### Examples

```coffeescript
# Print the current panel state name
panelBuilder = new VerticalPanel
print panelBuilder.content.states.current.name

# Create a panel and start it  with 'bottom' state and color red as background
panelBuilder = new VerticalPanel
	name: 'builder'
	initState: 'bottom'
	backgroundColor: 'red'

# Change properties of panel after created
panelBuilder.content.props = 
    backgrondColor = 'cyan'
    blur = 3

# Assing an image as background, overwrite defaut states heights
panelVehicle = new VerticalPanel
	name: 'vehicleSelector'
  	image: 'images/vehicles.png'
  	bottom: 5
  	middle: 30
  	top: 50

# Add a new state to the panel
panelVehicle.content.states.slideRight =
    x: Screen.width

panelVehicle.content.animate('slideRight')
```