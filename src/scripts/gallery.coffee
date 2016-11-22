TweenMax = require('gsap').TweenMax
CONST =
	DOM_NODE_MISSING: 'Please initialize Gallery with a DOM node.'
	ROOT_NODE: '[data-ui=gallery]'
	WRAPPER_SELECTOR: '[data-ui=gallery-wrapper]'
	ITEMS_SELECTOR: '[data-ui=gallery-items]'
	NAV_NEXT_SELECTOR: '[data-ui=gallery-nav-next]'
	NAV_PREV_SELECTOR: '[data-ui=gallery-nav-prev]'
	FIRST_CLASS: 'first'
	LAST_CLASS: 'last'
	ANIMATING_CLASS: 'animating'
	DIRECTION_FORWARD: 1
	DIRECTION_BACKWARD: -1

class Gallery

	constructor: (@domNode) ->
		if @domNode
			@attachNodes()
			@attachEvents()
			@init()
		else
			console.log CONST.DOM_NODE_MISSING

	attachNodes: ->
		@itemWrapperNode = @domNode.querySelector(CONST.ITEMS_SELECTOR)
		@nextNode = @domNode.querySelector(CONST.NAV_NEXT_SELECTOR)
		@prevNode = @domNode.querySelector(CONST.NAV_PREV_SELECTOR)

	attachEvents: ->
		if @nextNode
			@nextNode.addEventListener 'click', (e) => @navigationClickHandler(e, CONST.DIRECTION_FORWARD)
		if @prevNode
			@prevNode.addEventListener 'click', (e) => @navigationClickHandler(e, CONST.DIRECTION_BACKWARD)

		# Bind resize handler to window object
		@timeout = false
		@domNode.ownerDocument.defaultView.addEventListener 'resize', (e) => @resizeDebounceHandler(e)

	resizeDebounceHandler: ->
		clearTimeout @timeout
		@timeout = setTimeout(@resizeHandler, 250)
		return

	resizeHandler: =>
		# Reset gallery after resize
		@itemWrapperNode.scrollLeft = 0

	navigationClickHandler: (e, direction) ->
		e.preventDefault()
		@animate(@itemWrapperNode.offsetWidth, direction)

	animate: (pixels, direction) ->
		@domNode.classList.add CONST.ANIMATING_CLASS
		TweenMax.to @itemWrapperNode, .75,
			scrollLeft: '+=' + (pixels * direction),
			ease: Quad.easeInOut,
			onComplete: =>
				@domNode.classList.remove CONST.ANIMATING_CLASS
				@navigationDisplayHandler(direction)

	navigationDisplayHandler: (direction) ->
		@domNode.classList.remove CONST.LAST_CLASS
		@domNode.classList.remove CONST.FIRST_CLASS
		scrollWidth = @itemWrapperNode.scrollWidth
		scrollLeft = @itemWrapperNode.scrollLeft
		offsetWidth = @itemWrapperNode.offsetWidth

		if scrollLeft == 0
			@domNode.classList.add CONST.FIRST_CLASS

		if direction == CONST.DIRECTION_FORWARD and (offsetWidth + scrollLeft) >= scrollWidth - 1
			@domNode.classList.add CONST.LAST_CLASS

	init: ->
		@items = if @itemWrapperNode then @itemWrapperNode.children else []
		@navigationDisplayHandler()

module.exports = Gallery
module.exports.SELECTOR = CONST.ROOT_NODE
