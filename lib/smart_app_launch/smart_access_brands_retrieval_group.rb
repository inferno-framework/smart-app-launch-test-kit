require_relative 'smart_access_brands_retrieve_bundle_test'

module SMARTAppLaunch
  class SMARTAccessBrandsRetrievalGroup < Inferno::TestGroup
    id :smart_access_brands_retrieval
    title 'Retrieve SMART Access Brands Bundle'
    description %(
      A publisher's User Access Brand Bundle must be publicly available.  This test
      issues a HTTP GET request against the supplied URL and expects to receive
      the User Access Brand Bundle at this location.
    )

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@396',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@400'
    run_as_group

    http_client do
      url :user_access_brands_publication_url
      headers Accept: 'application/json, application/fhir+json'
    end

    test from: :smart_access_brands_retrieve_bundle
  end
end
