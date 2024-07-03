Extension { #name : 'RBClassRefactoring' }

{ #category : '*Webside' }
RBClassRefactoring >> asWebsideJson [

	^ super asWebsideJson
		  at: 'className' put: className;
		  yourself
]

{ #category : '*Webside' }
RBClassRefactoring >> fromWebsideJson: json [

	super fromWebsideJson: json.
	className := json at: 'className' ifAbsent: nil
]
