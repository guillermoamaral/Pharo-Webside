Extension { #name : #TestSuite }

{ #category : #'*Webside' }
TestSuite >> asWebsideJson [
	^ super asWebsideJson
		at: 'name' put: self name;
		yourself 
]
