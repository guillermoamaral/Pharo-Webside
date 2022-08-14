Extension { #name : #OCSemanticWarning }

{ #category : #'*Webside' }
OCSemanticWarning >> asWebsideJson [

	| interval |
	interval := NeoJSONObject new
		            at: 'start' put: node start;
		            at: 'end' put: node stop;
		            yourself.
	^ super asWebsideJson
		  at: 'description' put: self messageText;
		  at: 'interval' put: interval;
		  yourself
]
