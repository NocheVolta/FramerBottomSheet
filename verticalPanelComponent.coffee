class VerticalPanel extends Layer
	@define "content",
		importable: false
		exportable: false
		get: -> @options.verticalPanel
	constructor: (@options = {}) ->
		# Backgrounds and Colors
		@options.alphaColor ?= '#000'
		@options.backgroundColor ?= '#F0F0F0'
		@options.image ?= ''
		@options.name ?= 'verticalPanel'
		@options.indicator ?= true

		# States
		@options.initState ?= 'hidden'

		# Panel Sizes
		@options.bottom ?= 10
		@options.middle ?= 45
		@options.top ?= 90
		@options.animationDuration ?= 0.3

		# Screnn Dimensions
		@options.screenHeight = Screen.height
		@options.screenWidth = Screen.width

		# Percentage to Px
		statesHeights = 
			bottom: @_covertPercentageToPx(@options.screenHeight, @options.bottom)
			middle: @_covertPercentageToPx(@options.screenHeight, @options.middle)
			top: @_covertPercentageToPx(@options.screenHeight, @options.top)

		@options.states =
			hidden:
				y: @options.screenHeight
			bottom:
				y: statesHeights.bottom
			middle:
				y: statesHeights.middle
			top:
				y: statesHeights.top
		@_createLayers(statesHeights)

	# Convert percentage to pixels based on screen height
	_getSwipePageHeight: (screenHeight, percentage) ->
		Utils.round(screenHeight * (percentage / 100))
	
	# Covert percentage to pixels difference based on screen height
	_covertPercentageToPx:(screenHeight, percentage) ->
		Utils.round(screenHeight * ((100 - percentage) / 100))
	
	_addStates: (panel, states) ->
		panel.states = @options.states
		panel.stateSwitch(@options.initState)
	_createLayers: (statesHeights) ->
		wrapperPanel = new Layer
			backgroundColor: 'transparent'
			height: @options.screenHeight
			name: @options.name + '_wrapper'
			width: @options.screenWidth

		bgPanel = new Layer
			backgroundColor: @options.alphaColor
			height: @options.screenHeight
			name: @options.name + '_alpha'
			opacity: 0
			parent: wrapperPanel
			width: @options.screenWidth
			zIndex: -1

		@options.verticalPanel = verticalPanel = new Layer
			backgroundColor: @options.backgroundColor
			image: @options.image
			name: @options.name + '_content'
			parent: wrapperPanel
			shadowBlur: 2
			shadowColor: "rgba(0,0,0,0.08)"
			shadowY: -1
			borderRadius: 12
			# Dimensions
			height: @_getSwipePageHeight(@options.screenHeight, @options.top)
			width: @options.screenWidth

		if @options.indicator
			panelIndicator = new Layer
				backgroundColor: "rgba(34,34,64,0.16)"
				parent: verticalPanel
				borderRadius: 10
				height: 4
				width: 40
				x: Align.center
				y: 9

		@_addStates(verticalPanel, @options.states)
		@_setAnimationOptions(verticalPanel)
		@_registerPanelEvents(verticalPanel, bgPanel, statesHeights)

	_setAnimationOptions: (layer) ->
		layer.animationOptions =
			time: @options.animationDuration
		layer.draggable = true
		layer.draggable.horizontal = false
		layer.draggable.momentum = false

	_registerPanelEvents: (panel, background, statesHeights) ->
		posBottom = statesHeights.bottom
		posMiddle = statesHeights.middle
		posTop = statesHeights.top

		panel.onDragMove (event, layer) ->
			if layer.y <= posTop
				layer.y = posTop
			if layer.y >= posBottom
				layer.y = posBottom

		panel.on "change:y", =>
			if panel.y < posMiddle
				background.opacity = Utils.modulate(panel.y, [posMiddle, posTop], [0, 0.6], true)
			else 
				background.animate
					opacity: 0
					options:
						time: 0.1
		
		panel.onDragEnd (event, layer) ->
			direction = event.offsetDirection
			velocity = event.velocityY
				
			# If the gesture is too fast, then expand to top
			if velocity <= -3
				layer.animate('top')
			else if velocity <= -0.4 or direction == 'up'
				if posMiddle < layer.y < posBottom
					layer.animate('middle')
				else if  posMiddle > layer.y
					layer.animate('top')
				else 
					layer.animate('bottom')
			if direction == 'down' or velocity >= 0.4
				if posMiddle > layer.y > posTop
					layer.animate('middle')
				else if layer.y > posMiddle
					layer.animate('bottom')

module.exports = VerticalPanel;
