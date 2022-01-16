package br.pucrs.smart.ontology.mas;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Logger;

//import org.semanticweb.HermiT.Reasoner;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLLiteral;
import org.semanticweb.owlapi.model.OWLNamedIndividual;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLOntologyStorageException;
import org.semanticweb.owlapi.reasoner.OWLReasonerFactory;
import org.semanticweb.owlapi.reasoner.structural.StructuralReasonerFactory;

import cartago.Artifact;
import cartago.OPERATION;
import cartago.OpFeedbackParam;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Literal;
import jason.asSyntax.Term;
import br.pucrs.smart.ontology.OwlOntoLayer;

public class OntologyArtifact extends Artifact {
	private Logger logger = Logger.getLogger(OntologyArtifact.class.getName());
	
	private OwlOntoLayer onto = null;
	private OntoQueryLayerLiteral queryEngine;
	
	void init(String ontologyPath) {
		logger.info("Importing ontology from " + ontologyPath);
		try {
			this.onto = new OwlOntoLayer(ontologyPath);
			OWLReasonerFactory reasonerFactory = new StructuralReasonerFactory();			
			this.onto.setReasoner(reasonerFactory.createReasoner(this.onto.getOntology()));

			queryEngine = new OntoQueryLayerLiteral(this.onto);
			logger.info("Ontology ready!");
		} catch (OWLOntologyCreationException e) {
			logger.info("An error occurred when loading the ontology. Error: "+e.getMessage());
		} catch (Exception e) {
			logger.info("An unexpected error occurred: "+e.getMessage());
		}
	}
	
	/**
	 * @param instanceName Name of the new instance.
	 * @param conceptName Name of the concept which the new instance instances.
	 */
	@OPERATION
	void addInstance(String instanceName, String conceptName) {
		queryEngine.getQuery().addInstance(instanceName, conceptName);
	}
	
	/**
	 * @param instanceName Name of the new instance.
	 */
	@OPERATION
	void addInstance(String instanceName) {
		queryEngine.getQuery().addInstance(instanceName);
	}
	
	/**
	 * @param instanceName Name of the instance.
	 * @param conceptName Name of the concept.
	 * @return true if the <code>instanceName</code> instances <code>conceptName</code>.
	 */
	@OPERATION
	void isInstanceOf(String instanceName, String conceptName, OpFeedbackParam<Boolean> isInstance) {
		isInstance.set(queryEngine.getQuery().isInstanceOf(instanceName, conceptName));
	}
	
	/**
	 * @param conceptName Name of the concept.
	 * @param instances A free variable to receive the list of instances in the form of instances(concept,instance)
	 */
	@OPERATION
	void getInstances(String conceptName, OpFeedbackParam<Literal[]> instances){
		List<Object> individuals = queryEngine.getIndividualNames(conceptName);
		instances.set(individuals.toArray(new Literal[individuals.size()]));
	}
	
	/**
	* @return A list of ({@link OWLObjectProperty}).
	*/
	@OPERATION
	void getObjectPropertyNames(OpFeedbackParam<Literal[]> objectPropertyNames){
		List<Object> names = queryEngine.getObjectPropertyNames();
		objectPropertyNames.set(names.toArray(new Literal[names.size()]));
	}
	
	/**
	 * @param domainName Name of the instance ({@link OWLNamedIndividual}} which represent the property <i>domain</i>.
	 * @param propertyName Name of the new property.
	 * @param rangeName Name of the instance ({@link OWLNamedIndividual}} which represent the property <i>range</i>.
	 */
	@OPERATION
	void addProperty(String domainName, String propertyName, String rangeName) {
		queryEngine.getQuery().addProperty(domainName, propertyName, rangeName);
	}
	
	/**
	 * @param domainName Name of the instance which represents the domain of the property.
	 * @param propertyName Name of the property.
	 * @param rangeName Name of the instance which represents the range of the property.
	 * @return true if a instance of the property was found, false otherwise.
	 */
	@OPERATION
	void isRelated(String domainName, String propertyName, String rangeName, OpFeedbackParam<Boolean> isRelated) {
		isRelated.set(queryEngine.getQuery().isRelated(domainName, propertyName, rangeName));
	}
	
	@OPERATION
	void getObjectPropertyAssertions(OpFeedbackParam<Literal[]> opAssertions) {
		List<Object> assertions = queryEngine.getObjectPropertyAssertionAxioms();
		opAssertions.set(assertions.toArray(new Literal[assertions.size()]));
	}
	
	/**
	 * @param domain The name of the instance which corresponds to the domain of the property.
	 * @param propertyName Name of the property
	 * @return A list of ({@link OWLNamedIndividual}).
	 */
	@OPERATION
	void getObjectPropertyValues(String domain, String propertyName, OpFeedbackParam<String> instances) {
		List<String> individuals = new ArrayList<String>();
		for(OWLNamedIndividual individual : queryEngine.getQuery().getObjectPropertyValues(domain, propertyName)) {
			individuals.add(individual.getIRI().toString().substring(individual.getIRI().toString().indexOf('#')+1));
		}
		instances.set(individuals.toString());
	}
	
	/**
	 * @param domain The name of the instance which corresponds to the domain of the dataProperty.
	 * @param propertyName Name of the dataProperty
	 * @return A list of ({@link OWLLiteral}).
	 */
	@OPERATION
	void getDataPropertyValues(String domain, String propertyName, OpFeedbackParam<List<Term>> instances) {
		Collection<Term> terms = new LinkedList<Term>();		
		for(OWLLiteral literal : queryEngine.getQuery().getDataPropertyValues(domain, propertyName)) {
			terms.add(ASSyntax.createString(literal.toString().substring(1, literal.toString().indexOf('^')-1)));
		}
		instances.set(ASSyntax.createList(terms));
	}
	
	/**
	* @return A list of ({@link OWLClass}).
	*/
	@OPERATION
	void getClassNames(OpFeedbackParam<Literal[]> classes){
		List<Object> classNames = queryEngine.getClassNames();
		classes.set(classNames.toArray(new Literal[classNames.size()]));
	}
	
	
	/**
	 * @param conceptName Name of the new concept.
	 */
	@OPERATION
	void addConcept(String conceptName) {
		queryEngine.getQuery().addConcept(conceptName);
	}
	
	/**
	 * @param subConceptName Name of the supposed sub-concept.
	 * @param superConceptName Name of the concept to be tested as the super-concept.
	 * @return true if <code>subConceptName</code> is a sub-concept of <code>sueperConceptName</code>, false
	 * otherwise.
	 */
	@OPERATION
	void isSubConcept(String subConceptName, String superConceptName, OpFeedbackParam<Boolean> isSubConcept) {
		isSubConcept.set(queryEngine.getQuery().isSubConceptOf(subConceptName, superConceptName));
	}
		
	/**
	 * @param outputFile Path to the new file in the structure of directories.
	 * @throws OWLOntologyStorageException
	 */
	@OPERATION
	void saveOntotogy(String outputFile) {
		try {
			queryEngine.getQuery().saveOntology(outputFile);
		} catch (OWLOntologyStorageException e) {
			e.printStackTrace();
		}
	}
	
	/**
	* @return A list of ({@link OWLAnnotationProperty}).
	*/
	@OPERATION
	void getAnnotationPropertyNames(OpFeedbackParam<Literal[]> AnnotationPropertyNames){
		List<Object> names = queryEngine.getAnnotationPropertyNames();
		AnnotationPropertyNames.set(names.toArray(new Literal[names.size()]));
	}
	
	/**
	* @return A list of ({@link OWLDataProperty}).
	*/
	@OPERATION
	void getDataPropertyNames(OpFeedbackParam<Literal[]> dataPropertyNames){
		List<Object> names = queryEngine.getDataPropertyNames();
		System.out.println("DataPropertyNames");
		System.out.println(names.toString());
		dataPropertyNames.set(names.toArray(new Literal[names.size()]));
	}
	
		
}



















