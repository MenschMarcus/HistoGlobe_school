window.HG ?= {}

class HG.YearMarkerList extends HG.DoublyLinkedList

	_getByDate : (date) ->
		tmpIndex = 0
		tmpNode = @_head
		while tmpIndex < @_length
			if tmpNode.nodeData.getDate() == date
				return tmpNode.nodeData
			tmpNode = tmpNode.next
			tmpIndex++
		null

