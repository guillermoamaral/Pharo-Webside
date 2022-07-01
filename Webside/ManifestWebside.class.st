"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestWebside,
	#superclass : #PackageManifest,
	#category : #'Webside-Manifest'
}

{ #category : #'code-critics' }
ManifestWebside class >> ruleRBBadMessageRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#Webside)) #'2022-07-01T00:31:05.589714+00:00') )
]

{ #category : #'code-critics' }
ManifestWebside class >> ruleRBEqualsTrueRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#Webside)) #'2022-06-30T23:22:53.502643+00:00') )
]

{ #category : #'code-critics' }
ManifestWebside class >> ruleRBLongMethodsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#WebsideAPI #evaluateExpression #false)) #'2020-12-26T19:12:23.123875-03:00') )
]

{ #category : #'code-critics' }
ManifestWebside class >> ruleRBTempsReadBeforeWrittenRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#WebsideAPI #evaluateExpression #false)) #'2020-12-26T19:12:19.539558-03:00') )
]
