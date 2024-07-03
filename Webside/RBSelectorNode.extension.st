Extension { #name : 'RBSelectorNode' }

{ #category : '*Webside' }
RBSelectorNode >> asWebsideJson [

	^ super asWebsideJson
		  at: 'end' put: keywordPositions last + self keywords last size - 1;
		  at: 'value' put: value;
		  yourself
]
