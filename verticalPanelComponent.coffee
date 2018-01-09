class VerticalPanel extends Layer
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
    # Backgrounds and Colors
    @options.alphaColor ?= '#000'
    @options.backgroundColor ?= 'rgba(255,255,255,0.95)'
    @options.image ?= ''
    @options.name ?= 'verticalPanel'
    @options.indicator ?= true
    @options.draggable ?= true
    @options.fullHeight ?= false
    @options.alphaOpacity ?= 0.6

    # States
    @options.initState ?= 'hidden'
    @options.fallbackState ?= 'middle'

    # Panel
    @options.bottom ?= 10
    @options.middle ?= 45
    @options.top ?= 90
    @options.animationCurve ?= Spring(damping: 0.75)
    @options.animationDuration ?= 0.3
    @options.speedRatio ?= 0.75
    @options.tolerance ?= 30

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

    @options.ranges = [
      { max: statesHeights.top + @options.tolerance, min: statesHeights.top - @options.tolerance, name: 'top' }
      { max: statesHeights.middle + @options.tolerance, min: statesHeights.middle - @options.tolerance, name: 'middle' }
      { max: statesHeights.bottom + @options.tolerance, min: statesHeights.bottom - @options.tolerance, name: 'bottom' }
    ]

    @_createLayers(statesHeights)

  # Convert percentage to pixels based on screen height
  _getSwipePageHeight: (screenHeight, percentage) ->
    Utils.round(screenHeight * (percentage / 100))

  _getStateToSnap: (ranges, y) ->
    ranges.find((range) -> range.min <= y <= range.max)

  # Covert percentage to pixels difference based on screen height
  _covertPercentageToPx:(screenHeight, percentage) ->
    Utils.round(screenHeight * ((100 - percentage) / 100))

  # Convert pixels to percentage based on screen height
  _convertPxtoPercentage: (screenHeight, px) ->
    px * 100 / screenHeight

  _getDiff: (y, newY) ->
    Utils.round(Math.abs(y - newY) / @options.speedRatio) / 1000

  _addStates: (panel, states) ->
    panel.states = @options.states
    panel.stateSwitch(@options.initState)
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
        @options.screenHeight, @options.top) + @options.screenHeight * 0.1
      width: @options.screenWidth

    if @options.fullHeight then @options.verticalPanel.height = @options.screenHeight

    verticalPanel.style['border-radius'] = '16px 16px 0 0'

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

    @_addStates(verticalPanel, @options.states)
    @_setAnimationOptions(verticalPanel)
    @_registerPanelEvents(verticalPanel, bgPanel, statesHeights)

  _setAnimationOptions: (layer) ->
    layer.animationOptions =
      curve: @options.animationCurve
      time: @options.animationDuration
    if @options.draggable
      layer.draggable = true
      layer.draggable.horizontal = false
      layer.draggable.momentum = false

  _registerPanelEvents: (panel, background, statesHeights) ->
    posBottom = statesHeights.bottom
    posMiddle = statesHeights.middle
    posTop = statesHeights.top

    bgHandler = (event, layer) =>
      if panel.states.previous.name == panel.states.current.name or panel.states.previous.name == 'default'
        @animateTo(@options.fallbackState)
      else if layer.opacity == @options.alphaOpacity && panel.states.previous.name?
        @animateTo(panel.states.previous.name)

    if @options.initState != 'top'
      background.off(Events.Tap, bgHandler)
    else
      background.opacity = @options.alphaOpacity
      background.on(Events.Tap, bgHandler)

    panel.onStateSwitchEnd (from, to) ->
      if to == 'top' or panel.y == posTop
        background.on(Events.Tap, bgHandler)
        background.ignoreEvents = false
      else
        background.off(Events.Tap, bgHandler)
        background.ignoreEvents = true

    panel.onDragMove (event, layer) =>
      maxTop = posTop - @options.screenHeight * 0.1
      if layer.y <= 0
        layer.y = 0

    panel.on "change:y", =>
      if panel.y < posMiddle
        background.opacity = Utils.modulate(
          panel.y, [posMiddle, posTop], [0, @options.alphaOpacity], true
        )
      else
        background.animate
          opacity: 0
          options: time: 0.1

    panel.onDragEnd (event, layer) =>
      time = null
      y = layer.y
      direction = event.offsetDirection
      snapState = if @_getStateToSnap(@options.ranges, y) then @_getStateToSnap(@options.ranges, y).name else null
      nextState = layer.states.current.name
      velocity = Utils.round(Math.abs(event.velocityY), 2)
      percentage = Utils.round(Math.abs(@_convertPxtoPercentage(@options.screenHeight, event.offset.y)), 2)
      if layer.y <= posTop
        nextState = 'top'
      else if percentage >= 10 or velocity >= 0.25
          if direction == 'up'
            if posMiddle <= layer.y <= posBottom
              nextState = 'middle'
            else if posMiddle >= layer.y
              nextState = 'top'
            else
              nextState = 'bottom'
          else if direction == 'down'
            if posMiddle >= layer.y >= posTop
              nextState = 'middle'
            else if layer.y >= posMiddle
              nextState = 'bottom'

      nextState = snapState || nextState

      @animateTo(nextState, time)

  animateTo: (nextState, time = null) ->
    diff = time || Utils.round(
      @_getDiff(
        @options.verticalPanel.y
        @options.verticalPanel.states[nextState].y
        ), 3)
    if diff < 0.25 then diff = 0.25
    if !@options.verticalPanel.isAnimating
      @options.verticalPanel.animate(nextState, options: time: diff)

module.exports = VerticalPanel
