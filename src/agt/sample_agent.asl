/*
    Created by: Débora Engelmann
	June 21, 2021
*/

!start.

/* 
 * 
 * Plans to communicate with Dialogflow
 * 
 */
+request(ResponseId, IntentName, Params, Contexts)
	:true
<-
	.print("Request received ",IntentName," of Dialog");
	!responder(ResponseId, IntentName, Params, Contexts);
	.
	
+!responder(ResponseId, IntentName, Params, Contexts)
	: (IntentName == "Call Jason Agent")
<-
	reply("Hello, I am your agent Jason, I can help you?");
	.

	
+!responder(ResponseId, IntentName, Params, Contexts)
	: (IntentName == "Call Intent By Event")
<-
	replyWithEvent("Answering with an event", "testEvent");
	.

+!responder(ResponseId, IntentName, Params, Contexts)
	: (IntentName == "Intent Called By Event")
<-
	reply("Answering to an intention called by an event");
	.
	
+!responder(ResponseId, IntentName, Params, Contexts)
	: (IntentName == "Call With Contexts and Parameters")
<-
	.print("The contexts and parameters will be listed below.");
	!printContexts(Contexts);
	!printParameters(Params);
	reply("Hello, I'm your agent Jason, I received your contexts and parameters");
	.
	
+!responder(ResponseId, IntentName, Params, Contexts)
	: (IntentName == "Call With Contexts")
<-
	.print("The contexts will be listed below.");
	!printContexts(Contexts);
	reply("Hello, I am your agent Jason, I received your contexts");
	.
	
+!responder(ResponseId, IntentName, Params, Contexts)
	: (IntentName == "Reply With Context")
<-
	.print("The context will be created next.");
	contextBuilder(ResponseId, "test context", "1", Context);
	.print("Context created: ", Context);
	replyWithContext("Hello, I am your agent Jason, and I am responding with context", Context);
	.
	
+!responder(ResponseId, IntentName, Params, Contexts)
	: true
<-
	reply("Sorry, I do not recognize this intention");
	.

+!printContexts([]).
+!printContexts([Context|List])
<-
	.print(Context);
	!printContexts(List);
	.

+!printParameters([]).
+!printParameters([Param|List])
<-
	.print(Param)
	!printParameters(List)
	.
	
+!hello
    : True
<-
    .print("hello world");
    .



/* 
 * 
 * Plans to communicate with ontologies 
 * 
 * */

+!start 
	: true 
<- 
	.print("Assistant agent enabled.")
	.print("Let's use an ontology");
	!fillTheBeliefBase;	
		
	.print("Checking if patient Patient1 occupies bed 101a");
	!isRelated("Paciente1", ocupa_um, "101a", IsRelated);
	
	.print("Adding a new patient called JasonPatient")
	!addInstance("JasonPatient", paciente);
	!isInstanceOf("JasonPatient", paciente, Result);
	.print("Is PacienteJason an instance of Paciente? ", Result);
	
	.print("Adding a new ObjectProperty: Domain - 203c, PropertyName - e_ocupado_pelo, Range - JasonPatient");
	addProperty("203c", "e_ocupado_pelo", "JasonPatient");
	isRelated("203c", "e_ocupado_pelo", "JasonPatient", NewIsRelated);	
	.print("Is bed 203c now occupied by JasonPatient? ", NewIsRelated);
	
	.print("Checking if patient Patient2 occupies any bed");
	!getObjectPropertyValues("Paciente2", ocupa_um, Range);
	.print("The patient Patient2 occupies bed ", Range);
	
	.print("Getting AnnotationProperties in ontology");
	getAnnotationPropertyNames(AnnotationPropertyNames);
	!print("AnnotationPropertyNames",AnnotationPropertyNames);
	.print("Getting DataProperties in ontology");
	getDataPropertyNames(DataPropertyNames);
	!print("DataPropertyNames",DataPropertyNames);
	.

+!print(_,[]).	
+!print(Type,[H|T])
<-
	.print(Type," : ", H);
	!print(Type, T);
	.
	
+!fillTheBeliefBase
<- 
	.print("Getting classes in ontology");
	getClassNames(ClassNames);
	.print("Adding Classes to the belief base");
	!addToTheBeliefBase(ClassNames);
	.print("Getting ObjectProperties in ontology");
	getObjectPropertyNames(ObjectPropertyNames);
	.print("Adding ObjectProperties to the belief base");
	!addToTheBeliefBase(ObjectPropertyNames);
	.

+!addToTheBeliefBase([]).	
+!addToTheBeliefBase([H|T])
<-
	+H;
	!addToTheBeliefBase(T)
	.

+!isRelated(Domain, Property, Range, IsRelated)
 	: objectProperty(PropertyName,Property)
<-
	isRelated(Domain, PropertyName, Range, IsRelated);
	.print("Domain: ", Domain, " PropertyName: ", PropertyName, " Range: ", Range, " IsRelated: ", IsRelated);
	.
	
+!addInstance(InstanceName, Concept)
	: concept(ClassName,Concept)
<- 
	.print("Adding a new ", ClassName, " named ", InstanceName);
	addInstance(InstanceName, ClassName);
	!getInstances(Concept, Instances);
	!print("Instances", Instances);
	.

+!isInstanceOf(InstanceName, Concept, Result)
	: concept(ClassName,Concept)
<- 
	.print("Checking if ", InstanceName, " is an instance of ", ClassName);
	isInstanceOf(InstanceName, ClassName, Result);
	.print("The result is ", Result);
	!getInstances(Concept, Instances);
	!print("Instances", Instances);
	.

+!getInstances(Concept, Instances)
	: concept(ClassName,Concept)
<-
	.print("Getting instances of ", ClassName);
	getInstances(ClassName, Instances);
	.
	
+!getObjectPropertyValues(Domain, Property, Range)
 	: objectProperty(PropertyName,Property)
<-
	getObjectPropertyValues(Domain, PropertyName, Range);
	.print("Domain: ", Domain, " PropertyName: ", PropertyName, " Range: ", Range);
	.


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }