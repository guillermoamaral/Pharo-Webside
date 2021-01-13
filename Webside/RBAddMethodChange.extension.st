Extension { #name : #RBAddMethodChange }

{ #category : #'*Webside' }
RBAddMethodChange >> asWebsideJson [
	^ super asWebsideJson
		at: 'sourceCode' put: self source;
		at: 'selector' put: self selector;
		at: 'category' put: self protocol ;
		yourself
]

{ #category : #'*Webside' }
RBAddMethodChange >> fromWebsideJson: json [
	| category |
	super fromWebsideJson: json.
	selector := json at: 'selector' ifAbsent: nil.
	selector ifNotNil: [ selector := selector asSymbol ].
	source := json at: 'sourceCode'.
	category := json at: 'category' ifAbsent: nil.
	category ifNil: [ category := Protocol unclassified ].
	self protocols: {category asSymbol}
]

{ #category : #'*Webside' }
RBAddMethodChange class >> websideType [
	^ 'MethodDefinition'
]
