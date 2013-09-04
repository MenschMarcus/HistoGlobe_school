window.HG ?= {}


class HG.Beverage

	constructor: (price) ->
		@_price = price

	price: ->
		console.log "Ich koste #{@_price} Euro"







