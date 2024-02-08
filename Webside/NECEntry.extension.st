Extension { #name : #NECEntry }

{ #category : #'*Webside' }
NECEntry >> asWebsideJson [

	^ super asWebsideJson
		  at: 'label' put: self contents;
		  at: 'detail'
		  put:
			  (self description ifNotNil: [ :d | d description asString] ifNil: [ '' ]);
		  at: 'type' put: self websideType;
		  yourself
]

{ #category : #'*Webside' }
NECEntry >> websideType [
	^nil
]
