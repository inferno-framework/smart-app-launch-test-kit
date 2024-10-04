module SMARTAppLaunch
  class SMARTAccessBrandsRetrievalTest < Inferno::Test
    id :smart_access_brands_retrieve_bundle
    title 'Server returns publicly accessible SMART Access Brands Bundle'
    description %(
        Verify that the publisher's User Access Brands Bundle can be publicly
        accessed at the supplied URL location.
      )

    makes_request :bundle_request

    input :user_access_brands_publication_url,
          optional: true

    run do
      skip_if user_access_brands_publication_url.blank?, %(
        No User Access Brands Publication endpoint URL inputted. It is an expectation of the specification for the
        User Access Brands Bundle to be publicly available'
      )

      get(tags: ['smart_access_brands_bundle'])
      assert_response_status(200)
      assert(request.headers.any? { |header| header.name == 'access-control-allow-origin' }, %(
        All GET requests must support Cross-Origin Resource Sharing (CORS) for all GET requests to the artifacts
        described in this guide.))
      unless request.headers.any? { |header| header.name == 'etag' }
        add_message('warning', 'Brand Bundle HTTP responses should include an Etag header')
      end
    end
  end
end
