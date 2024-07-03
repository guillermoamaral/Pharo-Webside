Extension { #name : 'RBRenameClassChange' }

{ #category : '*Webside' }
RBRenameClassChange >> fromWebsideJson: json [

	super fromWebsideJson: json.
	oldName := json at: 'className' ifAbsent: nil.
	newName := json at: 'newName' ifAbsent: nil
]
