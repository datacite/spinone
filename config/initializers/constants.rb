RESCUABLE_EXCEPTIONS = [CanCan::AccessDenied,
                        JWT::VerificationError,
                        AbstractController::ActionNotFound,
                        ActionController::RoutingError,
                        ActionController::ParameterMissing,
                        ActionController::UnpermittedParameters,
                        NoMethodError]

# Format used for DOI validation
# The prefix is 10.x where x is 4-5 digits. The suffix can be anything, but can"t be left off
DOI_FORMAT = %r(\A10\.\d{4,5}/.+)

# Format used for URL validation
URL_FORMAT = %r(\A(http|https|ftp):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?\z)

# Form queue options
QUEUE_OPTIONS = ["high", "default", "low"]

# Version of ORCID API
ORCID_VERSION = '1.2'

# ORCID schema
ORCID_SCHEMA = 'https://raw.githubusercontent.com/ORCID/ORCID-Source/master/orcid-model/src/main/resources/orcid-message-1.2.xsd'

# Version of DataCite API
DATACITE_VERSION = "4"

# Date of DataCite Schema
DATACITE_SCHEMA_DATE = "2016-09-21"

# CSL types: https://github.com/citation-style-language/schema/blob/master/csl-types.rnc

# CrossRef types from http://api.crossref.org/types
CROSSREF_TYPE_TRANSLATIONS = {
  "proceedings" => nil,
  "reference-book" => nil,
  "journal-issue" => nil,
  "proceedings-article" => "paper-conference",
  "other" => nil,
  "dissertation" => "thesis",
  "dataset" => "dataset",
  "edited-book" => "book",
  "journal-article" => "article-journal",
  "journal" => nil,
  "report" => "report",
  "book-series" => nil,
  "report-series" => nil,
  "book-track" => nil,
  "standard" => nil,
  "book-section" => "chapter",
  "book-part" => nil,
  "book" => "book",
  "book-chapter" => "chapter",
  "standard-series" => nil,
  "monograph" => "book",
  "component" => nil,
  "reference-entry" => "entry-dictionary",
  "journal-volume" => nil,
  "book-set" => nil
}

# DataCite resourceTypeGeneral from DataCite metadata schema: https://doi.org/10.5438/0012
DATACITE_TYPE_TRANSLATIONS = {
  "Audiovisual" => "motion_picture",
  "Collection" => nil,
  "Dataset" => "dataset",
  "Event" => nil,
  "Image" => "graphic",
  "InteractiveResource" => nil,
  "Model" => nil,
  "PhysicalObject" => nil,
  "Service" => nil,
  "Software" => "computer_program",
  "Sound" => "song",
  "Text" => "report",
  "Workflow" => nil,
  "Other" => nil
}

# Map of DataCite work types to the CASRAI-based ORCID type vocabulary
# https://members.orcid.org/api/supported-work-types
TYPE_OF_WORK = {
  'Audiovisual' => 'other',
  'Collection' => 'other',
  'Dataset' =>  'data-set',
  'Event' => 'other',
  'Image' => 'other',
  'InteractiveResource' => 'online-resource',
  'Model' => 'other',
  'PhysicalObject' => 'other',
  'Service' => 'other',
  'Software' => 'other',
  'Sound' => 'other',
  'Text' => 'other',
  'Workflow' => 'other',
  'Other' => 'other',

  # Legacy types from older schema versions
  'Film' => 'other'
  # pick up other legacy types as we go along
}
