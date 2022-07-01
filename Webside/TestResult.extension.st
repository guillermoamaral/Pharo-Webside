Extension { #name : #TestResult }

{ #category : #'*Webside' }
TestResult >> asWebsideJson [
	^ super asWebsideJson
		at: 'passed' put: (passed collect: #asWebsideJson);
		at: 'failed' put: (failures collect: #asWebsideJson);
		at: 'errors' put: (errors collect: #asWebsideJson);
		at: 'skipped' put: (skipped collect: #asWebsideJson);
		yourself
		
		

]
