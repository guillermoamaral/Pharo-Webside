Extension { #name : #RBRefactoryClassChange }

{ #category : #'*Webside' }
RBRefactoryClassChange >> asWebsideJson [
	^ super asWebsideJson
		at: 'class' put: className ;
		yourself
]

{ #category : #'*Webside' }
RBRefactoryClassChange >> fromWebsideJson: json [

	super fromWebsideJson: json.
	className := json at: 'class' ifAbsent: nil.
	isMeta := className notNil and: [ className endsWith: ' class' ].
	className ifNotNil: [ 
		className := (className withoutSuffix: ' class') asSymbol ].
]
