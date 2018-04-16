defaultStates = [
  { name: 'bottom', height: 15 }
  { name: 'middle', height: 40 }
  { name: 'top', height: 90 }
]

class BottomSheet extends Layer
  @define "wrapper",
    importable: false
    exportable: false
    get: -> @options.wrapperPanel
  @define "content",
    importable: false
    exportable: false
    get: -> @options.verticalPanel
  @define "indicator",
    importable: false
    exportable: false
    get: -> @options.indicatorArea
  @define "state",
    importable: false
    exportable: false
    get: -> @options.verticalPanel.states.current.name
  constructor: (@options = {}) ->

    @options.alphaColor ?= '#000'
    @options.alphaOpacity ?= 0.6
    @options.animationCurve ?= Spring(damping: 0.75)
    @options.animationDuration ?= 0.3
    @options.backgroundColor ?= 'rgba(255,255,255,0.95)'
    @options.deltaTolerance ?= 1
    @options.draggable ?= true
    @options.hideable ?= true
    @options.image ?= ''
    @options.indicator ?= true
    @options.initState ?= null
    @options.name ?= 'verticalPanel'
    @options.screenHeight = Screen.height
    @options.screenWidth = Screen.width
    @options.states ?= defaultStates
    @options.speedRatio ?= 0.35
    @options.tolerance ?= 30

    @options.fallbackState ?= @options.states[0].name

    statesHeights = {}
    @options.ranges = []
    @options.highest = @options.screenHeight

    if @options.hideable
      @options.states.push { name: 'hidden', height: 0 }
    
    @options.states.sort (a, b) -> a.height - b.height

    @options.states.forEach((state, i) =>
      state.down = if @options.states[i - 1] then @options.states[i - 1].name else null
      state.up = if @options.states[i + 1] then @options.states[i + 1].name else null
      state.y = @_covertPercentageToPx(@options.screenHeight, state.height)

      statesHeights[state.name] = state.y

      @options.highest = Math.min state.y, @options.highest

      @options.ranges.push
        name: state.name
        max: state.y + @options.tolerance
        min: state.y - @options.tolerance
    )

    @_createLayers(statesHeights)

  _isNear: (val, target, threshold) ->
    Math.abs(val - target) <= threshold

  # Convert percentage to pixels based on screen height
  _getSwipePageHeight: (screenHeight, percentage) ->
    Utils.round(screenHeight * (percentage / 100))

  # Covert percentage to pixels difference based on screen height
  _covertPercentageToPx: (screenHeight, percentage) ->
    Utils.round(screenHeight * ((100 - percentage) / 100))

  # Convert pixels to percentage based on screen height
  _convertPxtoPercentage: (screenHeight, px) ->
    px * 100 / screenHeight

  _getDiff: (y, newY) ->
    Utils.round(Math.abs(y - newY) / @options.speedRatio) / 1000

  _getState: (currentState) =>
    @options.states.find (state) -> currentState == state.name

  _getClosestState: (y) =>
    prevState = closestState = null
    close = { y: 0 }
    @options.states.forEach((state) =>
      if @_isNear(y, state.y, @options.screenHeight * 0.10)
        if prevState
          diff = Math.abs y - state.y
          diff2 = Math.abs y - prevState.y
          if diff < diff2 then closestState = prevState
        closestState = state
        prevState = state
    )
    return closestState

  _addState: (panel, state) ->
    panel.states[state.name] = 
      y: state.y

  _createLayers: (statesHeights) ->
    @options.wrapperPanel = wrapperPanel = new Layer
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
      shadowBlur: 4
      shadowColor: "rgba(0,0,0,0.25)"
      shadowY: -1
      # Dimensions
      height: @_getSwipePageHeight(
        @options.screenHeight, @options.states[ @options.states.length - 1].height) + @options.screenHeight * 0.1
      width: @options.screenWidth

    if @options.indicator

      @options.indicatorArea = indicatorArea = new Layer
        name: 'indicator_area'
        backgroundColor: "transparent"
        width: verticalPanel.width
        height: 50
        parent: verticalPanel
        x: Align.center
        y: -30

      panelIndicator = new Layer
        name: 'panel_indicator'
        backgroundColor: "rgba(34,34,64,0.16)"
        parent: verticalPanel
        borderRadius: 10
        height: 4
        width: 40
        x: Align.center
        y: 9

    @options.states.forEach (state) => @_addState(verticalPanel, state)
    @_setAnimationOptions(verticalPanel)
    @_registerPanelEvents(verticalPanel, bgPanel, statesHeights)

    verticalPanel.stateSwitch @options.initState || @options.states[0].name

  _setAnimationOptions: (layer) ->
    layer.animationOptions =
      curve: @options.animationCurve
      time: @options.animationDuration
    if @options.draggable
      layer.draggable = true
      layer.draggable.horizontal = false
      layer.draggable.momentum = false

  _registerPanelEvents: (panel, background, statesHeights) ->
    higherState = @options.states[ @options.states.length - 2].y
    highestState = @options.states[ @options.states.length - 1].name
    highestStateY = @options.highest

    bgHandler = (event, layer) =>
      if panel.states.previous.name == panel.states.current.name or panel.states.previous.name == 'default'
        @animateTo(@options.fallbackState)
      else if layer.opacity == @options.alphaOpacity && panel.states.previous.name?
        @animateTo(panel.states.previous.name)

    if @options.initState != highestState
      background.off(Events.Tap, bgHandler)
    else
      background.opacity = @options.alphaOpacity
      background.on(Events.Tap, bgHandler)

    panel.onStateSwitchEnd (from, to) ->
      if to == highestState or panel.y == highestStateY
        background.on(Events.Tap, bgHandler)
        background.ignoreEvents = false
      else
        background.off(Events.Tap, bgHandler)
        background.ignoreEvents = true

    panel.onDragMove (event, layer) =>
      maxTop = highestStateY - @options.screenHeight * 0.1
      if layer.y <= 0 then layer.y = 0

    panel.onDragEnd (event, layer) =>
      y = layer.y
      time = null
      velocity = event.velocityY
      currentState = layer.states.current
      stateObj = @_getState currentState.name
      nextStateName = currentState.name
      closestState = @_getClosestState(y)

      switch event.offsetDirection
        when 'up', 'down'
          direction = event.offsetDirection
        else
          direction = false

      if velocity >= @options.deltaTolerance
        nextStateName = @options.states[0].name
      else if velocity <= @options.deltaTolerance * -1
        nextStateName = highestState
      else if direction and stateObj[direction]
        nextStateName = stateObj[direction]

      @animateTo nextStateName, time

    panel.on "change:y", =>
      if panel.y < higherState
        background.opacity = Utils.modulate(
          panel.y, [higherState, highestStateY], [0, @options.alphaOpacity], true
        )
      else
        background.animate
          opacity: 0
          options: time: 0.1

  animateTo: (nextState, time = null) ->
    diff = time || Utils.round(
      @_getDiff(
        @options.verticalPanel.y
        @options.verticalPanel.states[nextState].y
        ), 3)
    if diff < 0.25 then diff = 0.25
    if diff > 0.6 then diff = 0.6
    @options.verticalPanel.animate(nextState, options: time: diff)

module.exports = BottomSheet
