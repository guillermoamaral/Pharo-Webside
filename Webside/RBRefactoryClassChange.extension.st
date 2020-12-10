Extension { #name : #RBRefactoryClassChange }

{ #category : #'*Webside' }
RBRefactoryClassChange >> fromWebsideJson: json [
	super fromWebsideJson: json.
	className := json at: 'class' ifAbsent: nil.
	isMeta := className notNil and: [ className endsWith: ' class' ]
]
