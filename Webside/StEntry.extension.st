Extension { #name : 'StEntry' }

{ #category : '*Webside' }
StEntry >> asWebsideJson [

	^ super asWebsideJson
		  at: 'type' put: self websideType;
		  at: 'text' put: self asString;
		  yourself
]

{ #category : '*Webside' }
StEntry >> websideType [

	^ nil
]
