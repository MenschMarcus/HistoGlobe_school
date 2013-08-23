window.HG ?= {}

class HG.BeverageVendingMachine

	constructor: ->
		@_coffee = []
		@_tea = []
		@_vegetableStock = []

	addBeverage: (beverage) ->
		if beverage is "coffee"
			@_coffee.push new HG.Coffee 0.23, 5
		else if beverage is "tea"
			@_tea.push new HG.Tea 0.32, "fruity"
		else if beverage is "vegetable stock"
			@_vegetableStock.push new HG.VegetableStock 0.43, "water, ..."
		else
			console.log "gibt's nicht"


	getBeverage: (beverage) ->
		if beverage is "coffee"
			if @_coffee.length > 0
				return @_coffee.pop()
			else
				console.log "Der Kafffe ist leider alle."
				return undefined
		else if beverage is "tea"
			if @_tea.length > 0
				return @_tea.pop()
			else
				console.log "Der Tee ist leider alle."
				return undefined
		else if beverage is "vegetable stock"
			if @_vegetableStock.length > 0
				return @_vegetableStock.pop()
			else
				console.log "Die Gemüsebrühe ist leider alle."
				return undefined
		else return undefined		



automat = new HG.BeverageVendingMachine()
automat.addBeverage "coffee"
automat.addBeverage "tea"
automat.addBeverage "vegetable stock"


cup = automat.getBeverage "coffee"
cup.price()
automat.getBeverage "tea"
automat.getBeverage "vegetable stock"
cup = automat.getBeverage "tea"
cup?.price()