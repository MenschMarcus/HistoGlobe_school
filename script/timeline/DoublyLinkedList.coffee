
window.HG ?= {}

class HG.DoublyLinkedList

	constructor: () ->
		@_length = 0
		@_head = null
		@_tail = null

	addFirst : (data) ->
		node = 
			nodeData: data
			prev: null
			next: null
		if @_length == 0
			@_head = node
			@_tail = node
		else
			@_head.prev = node
			node.next = @_head
			@_head = node
		@_length++

	addLast : (data) ->
		node = 
			nodeData: data
			prev: null
			next: null
		if @_length == 0
			@_head = node
			@_tail = node
		else
			@_tail.next = node
			node.prev = @_tail
			@_tail = node
		@_length++
		

# class HG.Node

#  	constructor: (data) ->
# 		@_data = data
# 		@_prev = null
# 		@_next = null

# 	getPrev : () -> @_prev
# 	setPrev : (prev) -> @_prev = prev
# 	getNext : () -> @_next
# 	setNext : (next) -> @_next = next