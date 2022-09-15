Extension { #name : #RBRenameVariableChange }

{ #category : #'*Webside' }
RBRenameVariableChange >> asWebsideJson [

	^ super asWebsideJson
		  at: 'className' put: className;
		  at: 'variable' put: oldName;
		  at: 'newName' put: newName;
		  yourself
]

{ #category : #'*Webside' }
RBRenameVariableChange >> fromWebsideJson: json [

	super fromWebsideJson: json.
	className := json at: 'className' ifAbsent: nil.
	className ifNotNil: [ className := className asSymbol ].
	isMeta := className notNil and: [ className endsWith: ' class' ].
	oldName := json at: 'variable' ifAbsent: nil.
	newName := json at: 'newName' ifAbsent: nil
]
