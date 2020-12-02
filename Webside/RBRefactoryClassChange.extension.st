Extension { #name : #RBRefactoryClassChange }

{ #category : #'*Webside' }
RBRefactoryClassChange >> fromWebsideJson: json [
	super fromWebsideJson: json.
	self changeClassName:(json at: 'class') asSymbol.
	isMeta := className endsWith: ' class'
]
