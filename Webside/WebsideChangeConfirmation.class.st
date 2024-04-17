Class {
	#name : #WebsideChangeConfirmation,
	#superclass : #WebsideChangeError,
	#category : #Webside
}

{ #category : #accessing }
WebsideChangeConfirmation >> on: anException from: originalChange [
  super on: anException from: originalChange.
  self addSuggestion: self description changes: {originalChange}
]
