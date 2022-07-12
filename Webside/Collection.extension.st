Extension { #name : #Collection }

{ #category : #'*Webside' }
Collection >> asWebsideJson [
	| columns rows presentation json |
	columns := OrderedCollection new.
	columns
		add:
			(NeoJSONObject new
				at: 'field' put: 'index';
				at: 'label' put: '#';
				at: 'align' put: 'left';
				yourself);
		add:
			(NeoJSONObject new
				at: 'field' put: 'value';
				at: 'label' put: 'Value';
				at: 'align' put: 'left';
				yourself).
	[rows := self asArray
		withIndexCollect: [ :e :i | 
			NeoJSONObject new
				at: 'index' put: i;
				at: 'value' put: e asString;
				yourself ].
	presentation := NeoJSONObject new
		at: 'type' put: 'table';
		at: 'title' put: 'Items';
		at: 'columns' put: columns;
		at: 'rows' put: rows;
		yourself] on: Error do: [].
	json := super asWebsideJson.
	presentation ifNotNil: [ json at: 'presentation' put: presentation ].	
	^json
]
