Extension { #name : 'RBAddClassChange' }

{ #category : '*Webside' }
RBAddClassChange >> fromWebsideJson: json [

	| package tag superclass slots shared pools doit message submessage |
	super fromWebsideJson: json.
	builder := ShiftClassBuilder new.
	package := json at: 'package' ifAbsent: [  ].
	superclass := json at: 'superclass' ifAbsent: [  ].
	slots := json at: 'instanceVariables' ifAbsent: [ #(  ) ].
	shared := json at: 'classVariables' ifAbsent: [ #(  ) ].
	pools := json at: 'poolDictionaries' ifAbsent: [ #(  ) ].
	json
		at: 'definition'
		ifPresent: [ :definition | "arbitrary: if definition string is present, it has precendence over the other properties"
			doit := [
			        OpalCompiler new
				        isScripting: true;
				        parse: definition ]
				        on: OCUndeclaredVariableWarning , CodeError
				        do: [ :e |  ].
			message := doit body statements first value.
			superclass := message receiver receiver name.
			className := message receiver arguments first value asString.
			submessage := message messages
				              detect: [ :m | m selector == #slots: ]
				              ifNone: [  ].
			submessage ifNotNil: [
				slots := submessage arguments first statements collect: #value ].
			submessage := message messages
				              detect: [ :m | m selector == #sharedVariables: ]
				              ifNone: [  ].
			submessage ifNotNil: [
				shared := submessage arguments first statements collect: #value ].
			submessage := message messages
				              detect: [ :m | m selector == #sharedPools: ]
				              ifNone: [  ].
			submessage ifNotNil: [
				pools := submessage arguments first statements collect: #value ].
			submessage := message messages
				              detect: [ :m | m selector == #tag: ]
				              ifNone: [  ].
			submessage ifNotNil: [
				tag := submessage arguments first value asString ] ].
	builder
		package: package;
		superclassName: superclass;
		name: className;
		slots: slots;
		sharedVariables: shared;
		sharedPools: pools;
		tag: tag
]
