Extension { #name : #TestCase }

{ #category : #'*Webside' }
TestCase >> asWebsideJson [
	^ super asWebsideJson
		at: 'class' put: self class name;
		at: 'selector' put: testSelector;
		at: 'time' put: 0;
		at: 'seed' put: 0;
		yourself
]
