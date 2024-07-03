Extension { #name : 'RBRemoveMethodChange' }

{ #category : '*Webside' }
RBRemoveMethodChange >> asWebsideJson [
	^super asWebsideJson at: 'selector' put: selector; yourself
]

{ #category : '*Webside' }
RBRemoveMethodChange >> fromWebsideJson: json [

	super fromWebsideJson: json.
	selector := json at: 'selector' ifAbsent: nil.
	selector ifNotNil: [ selector := selector asSymbol ]
]
