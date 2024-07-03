Extension { #name : 'RGMethodDefinition' }

{ #category : '*Webside' }
RGMethodDefinition >> asWebsideJson [
	^ self compiledMethod asWebsideJson 
]
