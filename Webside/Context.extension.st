Extension { #name : 'Context' }

{ #category : '*Webside' }
Context >> asWebsideJson [

	^ NeoJSONObject new
		  at: 'label' put: self method printString;
		  at: 'class' put: self receiver class asWebsideJson;
		  at: 'method' put: self method asWebsideJson;
		  yourself
]
