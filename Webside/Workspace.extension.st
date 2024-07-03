Extension { #name : 'Workspace' }

{ #category : '*Webside' }
Workspace >> asWebsideJson [

	^ super asWebsideJson
		  at: 'source' put: self contents asString;
		  yourself
]
