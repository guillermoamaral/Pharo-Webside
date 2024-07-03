Extension { #name : 'RBNode' }

{ #category : '*Webside' }
RBNode >> asWebsideJson [

	^ super asWebsideJson
		  at: 'type' put: self websideType;
		  at: 'start' put: self start;
		  at: 'end' put: self stop;
		  yourself
]

{ #category : '*Webside' }
RBNode class >> websideType [ 
	^(self name withoutPrefix: 'RB') withoutSuffix: 'Node'.
]

{ #category : '*Webside' }
RBNode >> websideType [
	^self class websideType
]
