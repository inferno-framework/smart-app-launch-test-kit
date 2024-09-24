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
    run_as_group

    input :smart_access_brands_bundle_url,
          title: 'SMART Access Brands Bundle URL',
          description: %(
      The URL to the publisher's public SMART Access Brands List. Insert the SMART Access Brands URL
      if you host your Bundle at a public-facing endpoint and want Inferno to retrieve the Bundle from there.
    )

    http_client do
      url :smart_access_brands_bundle_url
      headers Accept: 'application/json, application/fhir+json'
    end

    test from: :smart_access_brands_retrieve_bundle
  end
end
