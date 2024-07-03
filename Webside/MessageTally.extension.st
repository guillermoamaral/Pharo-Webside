Extension { #name : 'MessageTally' }

{ #category : '*Webside' }
MessageTally >> asWebsideJson [

	^ self asWebsideJson: tally totalTime: time
]

{ #category : '*Webside' }
MessageTally >> asWebsideJson: total totalTime: totalTime [

	| percent label signature |
	percent := (tally asFloat / total * 100.0) rounded.
	signature := method
		             ifNil: [ '' ]
		             ifNotNil: [
		             method methodClass name , '>>' , method selector ].
	label := String streamContents: [ :strm |
		         strm
			         nextPutAll: percent asString;
			         nextPutAll: '% {';
			         nextPutAll: (percent * totalTime / 100) rounded asString;
			         nextPutAll: 'ms} ';
			         nextPutAll: signature ].
	^ NeoJSONObject new
		  at: 'label' put: label;
		  at: 'method' put: signature;
		  at: 'value' put: percent;
		  at: 'children'
		  put: ((receivers ifNil: [ #(  ) ]) collect: [ :mt |
					   mt asWebsideJson: total totalTime: totalTime ]);
		  yourself
]
