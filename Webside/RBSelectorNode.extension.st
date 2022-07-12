Extension { #name : #RBSelectorNode }

{ #category : #'*Webside' }
RBSelectorNode >> asWebsideJson [ 
^NeoJSONObject new
		     at: 'type' put: 'Selector';
		     at: 'start' put: self start;
		     at: 'end' put: self start + value size;
		     at: 'value' put: value;
		     yourself.
]
