Extension { #name : #Object }

{ #category : #'*Webside' }
Object >> asWebsideJson [
	^ self compiledMethod asWebsideJson 
]
