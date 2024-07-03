Extension { #name : 'RBAddMethodChange' }

{ #category : '*Webside' }
RBAddMethodChange >> asWebsideJson [
	| json |
	json := super asWebsideJson.
	self source ifNotNil: [ :s | json at: 'sourceCode' put: s ].
	^ json
		at: 'selector' put: self selector;
		at: 'category' put: self protocol;
		yourself
]

{ #category : '*Webside' }
RBAddMethodChange >> fromWebsideJson: json [

	| category ast |
	super fromWebsideJson: json.
	selector := json at: 'selector' ifAbsent: nil.
	selector ifNotNil: [ selector := selector asSymbol ].
	source := json at: 'sourceCode' ifAbsent: nil.
	source ifNotNil: [ "Enforce formatting as there is no option to skip formatting on Webside IDE ."
		ast := self parseTree.
		ast ifNotNil: [ source := RBProgramNode formatterClass format: ast ] ].
	category := json at: 'category' ifAbsent: nil.
	category ifNil: [ category := Protocol unclassified ].
	self protocols: { category asSymbol }
]
