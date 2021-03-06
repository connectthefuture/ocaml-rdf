
let owl_str = "http://www.w3.org/2002/07/owl#";;
let owl = Iri.of_string owl_str ;;
let owl_ s = Iri.of_string (owl_str ^ s);;

let c_AllDifferent = owl_ "AllDifferent" ;;
let c_AllDisjointClasses = owl_ "AllDisjointClasses" ;;
let c_AllDisjointProperties = owl_ "AllDisjointProperties" ;;
let c_Annotation = owl_ "Annotation" ;;
let c_AnnotationProperty = owl_ "AnnotationProperty" ;;
let c_AsymmetricProperty = owl_ "AsymmetricProperty" ;;
let c_Axiom = owl_ "Axiom" ;;
let c_Class = owl_ "Class" ;;
let c_DataRange = owl_ "DataRange" ;;
let c_DatatypeProperty = owl_ "DatatypeProperty" ;;
let c_DeprecatedClass = owl_ "DeprecatedClass" ;;
let c_DeprecatedProperty = owl_ "DeprecatedProperty" ;;
let c_FunctionalProperty = owl_ "FunctionalProperty" ;;
let c_InverseFunctionalProperty = owl_ "InverseFunctionalProperty" ;;
let c_IrreflexiveProperty = owl_ "IrreflexiveProperty" ;;
let c_NamedIndividual = owl_ "NamedIndividual" ;;
let c_NegativePropertyAssertion = owl_ "NegativePropertyAssertion" ;;
let c_Nothing = owl_ "Nothing" ;;
let c_ObjectProperty = owl_ "ObjectProperty" ;;
let c_Ontology = owl_ "Ontology" ;;
let c_OntologyProperty = owl_ "OntologyProperty" ;;
let c_ReflexiveProperty = owl_ "ReflexiveProperty" ;;
let c_Restriction = owl_ "Restriction" ;;
let c_SymmetricProperty = owl_ "SymmetricProperty" ;;
let c_Thing = owl_ "Thing" ;;
let c_TransitiveProperty = owl_ "TransitiveProperty" ;;
let allValuesFrom = owl_ "allValuesFrom" ;;
let annotatedProperty = owl_ "annotatedProperty" ;;
let annotatedSource = owl_ "annotatedSource" ;;
let annotatedTarget = owl_ "annotatedTarget" ;;
let assertionProperty = owl_ "assertionProperty" ;;
let backwardCompatibleWith = owl_ "backwardCompatibleWith" ;;
let bottomDataProperty = owl_ "bottomDataProperty" ;;
let bottomObjectProperty = owl_ "bottomObjectProperty" ;;
let cardinality = owl_ "cardinality" ;;
let complementOf = owl_ "complementOf" ;;
let datatypeComplementOf = owl_ "datatypeComplementOf" ;;
let deprecated = owl_ "deprecated" ;;
let differentFrom = owl_ "differentFrom" ;;
let disjointUnionOf = owl_ "disjointUnionOf" ;;
let disjointWith = owl_ "disjointWith" ;;
let distinctMembers = owl_ "distinctMembers" ;;
let equivalentClass = owl_ "equivalentClass" ;;
let equivalentProperty = owl_ "equivalentProperty" ;;
let hasKey = owl_ "hasKey" ;;
let hasSelf = owl_ "hasSelf" ;;
let hasValue = owl_ "hasValue" ;;
let incompatibleWith = owl_ "incompatibleWith" ;;
let intersectionOf = owl_ "intersectionOf" ;;
let inverseOf = owl_ "inverseOf" ;;
let maxCardinality = owl_ "maxCardinality" ;;
let maxQualifiedCardinality = owl_ "maxQualifiedCardinality" ;;
let members = owl_ "members" ;;
let minCardinality = owl_ "minCardinality" ;;
let minQualifiedCardinality = owl_ "minQualifiedCardinality" ;;
let onClass = owl_ "onClass" ;;
let onDataRange = owl_ "onDataRange" ;;
let onDatatype = owl_ "onDatatype" ;;
let onProperties = owl_ "onProperties" ;;
let onProperty = owl_ "onProperty" ;;
let oneOf = owl_ "oneOf" ;;
let priorVersion = owl_ "priorVersion" ;;
let propertyChainAxiom = owl_ "propertyChainAxiom" ;;
let propertyDisjointWith = owl_ "propertyDisjointWith" ;;
let qualifiedCardinality = owl_ "qualifiedCardinality" ;;
let sameAs = owl_ "sameAs" ;;
let someValuesFrom = owl_ "someValuesFrom" ;;
let sourceIndividual = owl_ "sourceIndividual" ;;
let targetIndividual = owl_ "targetIndividual" ;;
let targetValue = owl_ "targetValue" ;;
let topDataProperty = owl_ "topDataProperty" ;;
let topObjectProperty = owl_ "topObjectProperty" ;;
let unionOf = owl_ "unionOf" ;;
let versionInfo = owl_ "versionInfo" ;;
let withRestrictions = owl_ "withRestrictions" ;;

module Open = struct
  let owl_c_AllDifferent = c_AllDifferent
  let owl_c_AllDisjointClasses = c_AllDisjointClasses
  let owl_c_AllDisjointProperties = c_AllDisjointProperties
  let owl_c_Annotation = c_Annotation
  let owl_c_AnnotationProperty = c_AnnotationProperty
  let owl_c_AsymmetricProperty = c_AsymmetricProperty
  let owl_c_Axiom = c_Axiom
  let owl_c_Class = c_Class
  let owl_c_DataRange = c_DataRange
  let owl_c_DatatypeProperty = c_DatatypeProperty
  let owl_c_DeprecatedClass = c_DeprecatedClass
  let owl_c_DeprecatedProperty = c_DeprecatedProperty
  let owl_c_FunctionalProperty = c_FunctionalProperty
  let owl_c_InverseFunctionalProperty = c_InverseFunctionalProperty
  let owl_c_IrreflexiveProperty = c_IrreflexiveProperty
  let owl_c_NamedIndividual = c_NamedIndividual
  let owl_c_NegativePropertyAssertion = c_NegativePropertyAssertion
  let owl_c_Nothing = c_Nothing
  let owl_c_ObjectProperty = c_ObjectProperty
  let owl_c_Ontology = c_Ontology
  let owl_c_OntologyProperty = c_OntologyProperty
  let owl_c_ReflexiveProperty = c_ReflexiveProperty
  let owl_c_Restriction = c_Restriction
  let owl_c_SymmetricProperty = c_SymmetricProperty
  let owl_c_Thing = c_Thing
  let owl_c_TransitiveProperty = c_TransitiveProperty
  let owl_allValuesFrom = allValuesFrom
  let owl_annotatedProperty = annotatedProperty
  let owl_annotatedSource = annotatedSource
  let owl_annotatedTarget = annotatedTarget
  let owl_assertionProperty = assertionProperty
  let owl_backwardCompatibleWith = backwardCompatibleWith
  let owl_bottomDataProperty = bottomDataProperty
  let owl_bottomObjectProperty = bottomObjectProperty
  let owl_cardinality = cardinality
  let owl_complementOf = complementOf
  let owl_datatypeComplementOf = datatypeComplementOf
  let owl_deprecated = deprecated
  let owl_differentFrom = differentFrom
  let owl_disjointUnionOf = disjointUnionOf
  let owl_disjointWith = disjointWith
  let owl_distinctMembers = distinctMembers
  let owl_equivalentClass = equivalentClass
  let owl_equivalentProperty = equivalentProperty
  let owl_hasKey = hasKey
  let owl_hasSelf = hasSelf
  let owl_hasValue = hasValue
  let owl_incompatibleWith = incompatibleWith
  let owl_intersectionOf = intersectionOf
  let owl_inverseOf = inverseOf
  let owl_maxCardinality = maxCardinality
  let owl_maxQualifiedCardinality = maxQualifiedCardinality
  let owl_members = members
  let owl_minCardinality = minCardinality
  let owl_minQualifiedCardinality = minQualifiedCardinality
  let owl_onClass = onClass
  let owl_onDataRange = onDataRange
  let owl_onDatatype = onDatatype
  let owl_onProperties = onProperties
  let owl_onProperty = onProperty
  let owl_oneOf = oneOf
  let owl_priorVersion = priorVersion
  let owl_propertyChainAxiom = propertyChainAxiom
  let owl_propertyDisjointWith = propertyDisjointWith
  let owl_qualifiedCardinality = qualifiedCardinality
  let owl_sameAs = sameAs
  let owl_someValuesFrom = someValuesFrom
  let owl_sourceIndividual = sourceIndividual
  let owl_targetIndividual = targetIndividual
  let owl_targetValue = targetValue
  let owl_topDataProperty = topDataProperty
  let owl_topObjectProperty = topObjectProperty
  let owl_unionOf = unionOf
  let owl_versionInfo = versionInfo
  let owl_withRestrictions = withRestrictions
end

class from ?sub g =
  let sub = match sub with None -> g.Rdf_graph.name() | Some iri -> iri in
  let sub = Rdf_term.Iri sub in
  object
  method allValuesFrom = Rdf_graph.iri_objects_of g ~sub ~pred: allValuesFrom
  method annotatedProperty = Rdf_graph.iri_objects_of g ~sub ~pred: annotatedProperty
  method annotatedSource = Rdf_graph.iri_objects_of g ~sub ~pred: annotatedSource
  method annotatedTarget = Rdf_graph.iri_objects_of g ~sub ~pred: annotatedTarget
  method assertionProperty = Rdf_graph.iri_objects_of g ~sub ~pred: assertionProperty
  method backwardCompatibleWith = Rdf_graph.iri_objects_of g ~sub ~pred: backwardCompatibleWith
  method bottomDataProperty = Rdf_graph.literal_objects_of g ~sub ~pred: bottomDataProperty
  method bottomObjectProperty = Rdf_graph.iri_objects_of g ~sub ~pred: bottomObjectProperty
  method cardinality = Rdf_graph.iri_objects_of g ~sub ~pred: cardinality
  method complementOf = Rdf_graph.iri_objects_of g ~sub ~pred: complementOf
  method datatypeComplementOf = Rdf_graph.literal_objects_of g ~sub ~pred: datatypeComplementOf
  method deprecated = Rdf_graph.iri_objects_of g ~sub ~pred: deprecated
  method differentFrom = Rdf_graph.iri_objects_of g ~sub ~pred: differentFrom
  method disjointUnionOf = Rdf_graph.iri_objects_of g ~sub ~pred: disjointUnionOf
  method disjointWith = Rdf_graph.iri_objects_of g ~sub ~pred: disjointWith
  method distinctMembers = Rdf_graph.iri_objects_of g ~sub ~pred: distinctMembers
  method equivalentClass = Rdf_graph.iri_objects_of g ~sub ~pred: equivalentClass
  method equivalentProperty = Rdf_graph.iri_objects_of g ~sub ~pred: equivalentProperty
  method hasKey = Rdf_graph.iri_objects_of g ~sub ~pred: hasKey
  method hasSelf = Rdf_graph.iri_objects_of g ~sub ~pred: hasSelf
  method hasValue = Rdf_graph.iri_objects_of g ~sub ~pred: hasValue
  method incompatibleWith = Rdf_graph.iri_objects_of g ~sub ~pred: incompatibleWith
  method intersectionOf = Rdf_graph.iri_objects_of g ~sub ~pred: intersectionOf
  method inverseOf = Rdf_graph.iri_objects_of g ~sub ~pred: inverseOf
  method maxCardinality = Rdf_graph.iri_objects_of g ~sub ~pred: maxCardinality
  method maxQualifiedCardinality = Rdf_graph.iri_objects_of g ~sub ~pred: maxQualifiedCardinality
  method members = Rdf_graph.iri_objects_of g ~sub ~pred: members
  method minCardinality = Rdf_graph.iri_objects_of g ~sub ~pred: minCardinality
  method minQualifiedCardinality = Rdf_graph.iri_objects_of g ~sub ~pred: minQualifiedCardinality
  method onClass = Rdf_graph.iri_objects_of g ~sub ~pred: onClass
  method onDataRange = Rdf_graph.literal_objects_of g ~sub ~pred: onDataRange
  method onDatatype = Rdf_graph.literal_objects_of g ~sub ~pred: onDatatype
  method onProperties = Rdf_graph.iri_objects_of g ~sub ~pred: onProperties
  method onProperty = Rdf_graph.iri_objects_of g ~sub ~pred: onProperty
  method oneOf = Rdf_graph.iri_objects_of g ~sub ~pred: oneOf
  method priorVersion = Rdf_graph.iri_objects_of g ~sub ~pred: priorVersion
  method propertyChainAxiom = Rdf_graph.iri_objects_of g ~sub ~pred: propertyChainAxiom
  method propertyDisjointWith = Rdf_graph.iri_objects_of g ~sub ~pred: propertyDisjointWith
  method qualifiedCardinality = Rdf_graph.iri_objects_of g ~sub ~pred: qualifiedCardinality
  method sameAs = Rdf_graph.iri_objects_of g ~sub ~pred: sameAs
  method someValuesFrom = Rdf_graph.iri_objects_of g ~sub ~pred: someValuesFrom
  method sourceIndividual = Rdf_graph.iri_objects_of g ~sub ~pred: sourceIndividual
  method targetIndividual = Rdf_graph.iri_objects_of g ~sub ~pred: targetIndividual
  method targetValue = Rdf_graph.literal_objects_of g ~sub ~pred: targetValue
  method topDataProperty = Rdf_graph.literal_objects_of g ~sub ~pred: topDataProperty
  method topObjectProperty = Rdf_graph.iri_objects_of g ~sub ~pred: topObjectProperty
  method unionOf = Rdf_graph.iri_objects_of g ~sub ~pred: unionOf
  method versionInfo = Rdf_graph.iri_objects_of g ~sub ~pred: versionInfo
  method withRestrictions = Rdf_graph.iri_objects_of g ~sub ~pred: withRestrictions
  end
