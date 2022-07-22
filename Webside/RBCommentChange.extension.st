Extension { #name : #RBCommentChange }

{ #category : #'*Webside' }
RBCommentChange >> asWebsideJson [
	^super asWebsideJson
		at: 'comment' put: comment; yourself
]

{ #category : #'*Webside' }
RBCommentChange >> fromWebsideJson: json [
	super fromWebsideJson: json.
	comment := json at: 'comment' ifAbsent: ''
]

{ #category : #'*Webside' }
RBCommentChange class >> websideType [

	^ 'CommentClass'
]
