Extension { #name : #RBCommentChange }

{ #category : #'*Webside' }
RBCommentChange >> fromWebsideJson: json [
	super fromWebsideJson: json.
	comment := json at: 'comment' ifAbsent: ''
]

{ #category : #'*Webside' }
RBCommentChange class >> webSTType [
	^ 'ClassCommentDefinition'
]
