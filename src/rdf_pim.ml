
let pim_str = "http://www.w3.org/ns/pim/space#";;
let pim = Iri.of_string pim_str ;;
let pim_ s = Iri.of_string (pim_str ^ s);;

let c_ConfigurationFile = pim_ "ConfigurationFile" ;;
let c_ControlledStorage = pim_ "ControlledStorage" ;;
let c_MasterWorkspace = pim_ "MasterWorkspace" ;;
let c_PersonalStorage = pim_ "PersonalStorage" ;;
let c_PreferencesWorkspace = pim_ "PreferencesWorkspace" ;;
let c_PrivateWorkspace = pim_ "PrivateWorkspace" ;;
let c_PublicStorage = pim_ "PublicStorage" ;;
let c_PublicWorkspace = pim_ "PublicWorkspace" ;;
let c_SharedWorkspace = pim_ "SharedWorkspace" ;;
let c_Storage = pim_ "Storage" ;;
let c_Workspace = pim_ "Workspace" ;;
let masterWorkspace = pim_ "masterWorkspace" ;;
let preferencesFile = pim_ "preferencesFile" ;;
let storage = pim_ "storage" ;;
let uriPrefix = pim_ "uriPrefix" ;;
let workspace = pim_ "workspace" ;;

module Open = struct
  let pim_c_ConfigurationFile = c_ConfigurationFile
  let pim_c_ControlledStorage = c_ControlledStorage
  let pim_c_MasterWorkspace = c_MasterWorkspace
  let pim_c_PersonalStorage = c_PersonalStorage
  let pim_c_PreferencesWorkspace = c_PreferencesWorkspace
  let pim_c_PrivateWorkspace = c_PrivateWorkspace
  let pim_c_PublicStorage = c_PublicStorage
  let pim_c_PublicWorkspace = c_PublicWorkspace
  let pim_c_SharedWorkspace = c_SharedWorkspace
  let pim_c_Storage = c_Storage
  let pim_c_Workspace = c_Workspace
  let pim_masterWorkspace = masterWorkspace
  let pim_preferencesFile = preferencesFile
  let pim_storage = storage
  let pim_uriPrefix = uriPrefix
  let pim_workspace = workspace
end

class from ?sub g =
  let sub = match sub with None -> g.Rdf_graph.name() | Some iri -> iri in
  let sub = Rdf_term.Iri sub in
  object
  method masterWorkspace = Rdf_graph.iri_objects_of g ~sub ~pred: masterWorkspace
  method preferencesFile = Rdf_graph.iri_objects_of g ~sub ~pred: preferencesFile
  method storage = Rdf_graph.iri_objects_of g ~sub ~pred: storage
  method uriPrefix = Rdf_graph.iri_objects_of g ~sub ~pred: uriPrefix
  method workspace = Rdf_graph.iri_objects_of g ~sub ~pred: workspace
  end
