Extension { #name : #StMethodEntry }

{ #category : #'*Webside' }
StMethodEntry >> websideType [
    "This might not look correct but the current Webside quick search looks for selectors,
    and it is implemented here (Pharo) by using Spotter search engine."
	^ 'selector'
]
