Extension { #name : #RBCascadeNode }

{ #category : #'*Webside' }
RBCascadeNode >> asWebsideJson [ 
| children |
children := messages collect: [ :n | n asWebsideJson  ].
^super asWebsideJson at: 'children' put: children; yourself 
]
