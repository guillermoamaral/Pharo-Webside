Extension { #name : #RBRenameClassChange }

{ #category : #'*Webside' }
RBRenameClassChange >> fromWebsideJson: json [
	super fromWebsideJson: json.
	oldName := json at: 'class' ifAbsent: nil.
	newName := json at: 'newName' ifAbsent: nil.
]

{ #category : #'*Webside' }
RBRenameClassChange class >> webSTType [
	^ 'ClassRename'
]
