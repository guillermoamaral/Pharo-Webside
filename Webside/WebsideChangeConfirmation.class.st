Class {
	#name : 'WebsideChangeConfirmation',
	#superclass : 'WebsideChangeError',
	#category : 'Webside-Base',
	#package : 'Webside',
	#tag : 'Base'
}

{ #category : 'as yet unclassified' }
WebsideChangeConfirmation class >> confirm: originalChange asking: question [

	^ self new confirm: originalChange asking: question
]

{ #category : 'json' }
WebsideChangeConfirmation >> asWebsideJson [

	| json |
	json := super asWebsideJson.
	((json at: 'suggestions') first at: 'changes') first
		at: 'confirmed'
		put: true.
	^ json
]

{ #category : 'accessing' }
WebsideChangeConfirmation >> confirm: originalChange asking: question [

	change := originalChange.
	messageText := 'Confirm'.
	self
		suggest: question withChanges: { originalChange };
		signal
]

{ #category : 'accessing' }
WebsideChangeConfirmation >> description [

	^ messageText
]
