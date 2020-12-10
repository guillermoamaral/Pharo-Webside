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
	className ifNotNil: [ className := className asSymbol ].
	isMeta := className notNil and: [ className endsWith: ' class' ]
	
]
