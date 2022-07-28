Extension { #name : #Dictionary }

{ #category : #'*Webside' }
Dictionary >> asWebsideJson [

	| columns rows presentation |
	columns := OrderedCollection new.
	columns
		add: (NeoJSONObject new
				 at: 'field' put: 'key';
				 at: 'label' put: 'Key';
				 at: 'align' put: 'left';
				 yourself);
		add: (NeoJSONObject new
				 at: 'field' put: 'value';
				 at: 'label' put: 'Value';
				 at: 'align' put: 'left';
				 yourself).
	rows := self keysSortedSafely  collect: [ :k | 
		        NeoJSONObject new
			        at: 'key' put: k asString;
			        at: 'value' put: (self at: k) asString;
			        yourself ].
	presentation := NeoJSONObject new
		                at: 'type' put: 'table';
		                at: 'title' put: 'Items';
		                at: 'columns' put: columns;
		                at: 'rows' put: rows;
		                yourself.
	^ super asWebsideJson
		  at: 'presentation' put: presentation;
		  yourself
]
