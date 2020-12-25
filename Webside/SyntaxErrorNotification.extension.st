Extension { #name : #SyntaxErrorNotification }

{ #category : #'*Webside' }
SyntaxErrorNotification >> asWebsideJson [
	| interval |
	interval := NeoJSONObject new
		at: 'start' put: location;
		at: 'end' put: location; yourself.
	^ NeoJSONObject new
		at: 'description' put: self messageText;
		at: 'interval' put: interval;
		yourself
		
]
