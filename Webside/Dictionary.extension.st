Extension { #name : #Dictionary }

{ #category : #'*Webside' }
Dictionary >> asWebsideJson [
	| columns rows presentation |
	columns := OrderedCollection new.
	columns
		add:
			(NeoJSONObject new
				at: 'field' put: 'key';
				at: 'label' put: 'Key';
				at: 'align' put: 'left';
				yourself);
		add:
			(NeoJSONObject new
				at: 'field' put: 'value';
				at: 'label' put: 'Value';
				at: 'align' put: 'left';
				yourself).
	rows := self associations
		collect: [ :a | 
			NeoJSONObject new
				at: 'key' put: a key asString ;
				at: 'value' put: a value asString;
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
