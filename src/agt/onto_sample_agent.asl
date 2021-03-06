/*
    Created by: Débora Engelmann
	June 21, 2021
*/

!start.

/* 
 * 
 * Plans to communicate with ontologies 
 * 
 * */

+!start 
	: true 
<- 
	.print("Onto agent enabled.")
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

	.print("Checking if patient Patient1 has teste-string");
	!getDataPropertyValues("Paciente1", teste_string, Rn);
	.print("The patient Patient1 has teste-string: ", Rn);
	!print("DataProperty", Rn);
	
	.print("Checking if patient Patient1 has tem-idade");
	!getDataPropertyValues("Paciente1", tem_idade, Rg);
	.print("The patient Patient1 has tem-idade: ", Rg);
	!print("DataProperty", Rg);
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
	getDataPropertyNames(DataProperties);
	.print("Adding DataProperties to the belief base");
	!addToTheBeliefBase(DataProperties);
	getObjectPropertyAssertions(Assertions);
	.print("Adding Assertions to the belief base");
	!addToTheBeliefBase(Assertions);
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
	
+!getDataPropertyValues(Domain, Property, Range)
 	: dataProperty(PropertyName,Property)
<-
	getDataPropertyValues(Domain, PropertyName, Range);
	.print("Domain: ", Domain, " PropertyName: ", PropertyName, " Range: ", Range);
	.


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }