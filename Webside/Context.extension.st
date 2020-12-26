Extension { #name : #Context }

{ #category : #'*Webside' }
Context >> asWebsideJson [ 
	| interval |
	interval := self pcRange.
	interval := NeoJSONObject new at: 'start' put: interval first; at: 'end' put: interval end; yourself.
	^NeoJSONObject new at: 'label' put: self method printString;
	at: 'class' put: self receiver class asWebsideJson ;
	at: 'method' put: self method asWebsideJson ;
	at: 'interval' put: interval; yourself 
]
