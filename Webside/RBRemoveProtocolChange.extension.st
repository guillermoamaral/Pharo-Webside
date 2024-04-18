Extension { #name : #RBRemoveProtocolChange }

{ #category : #'*Webside' }
RBRemoveProtocolChange >> websideExecute: ensure [

	| category |
	ensure ifTrue: [ ^ super websideExecute: ensure ].
	category := self changeClass organization protocolNamed: protocol.
	category isEmpty ifTrue: [ ^ super websideExecute: ensure ].
	WebsideChangeConfirmation
		confirm: self
		asking:
		'Category is not empty. Do you want to remove all category methods?'
]

{ #category : #'*Webside' }
RBRemoveProtocolChange class >> websideType [

	^ 'RemoveCategory'
]
