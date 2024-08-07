Extension { #name : 'RBRefactoryClassChange' }

{ #category : '*Webside' }
RBRefactoryClassChange >> asWebsideJson [

	| moniker |
	moniker := className ifNotNil: [ 
		           isMeta
			           ifTrue: [ className , ' class' ]
			           ifFalse: [ className ] ].
	^ super asWebsideJson
		  at: 'className' put: moniker asString;
		  yourself
]

{ #category : '*Webside' }
RBRefactoryClassChange >> fromWebsideJson: json [

	super fromWebsideJson: json.
	className := json at: 'className' ifAbsent: nil.
	isMeta := className notNil and: [ className endsWith: ' class' ].
	className ifNotNil: [ 
		className := (className withoutSuffix: ' class') asSymbol ]
]
