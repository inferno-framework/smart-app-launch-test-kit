module SMARTAppLaunch
  class SMARTAccessBrandsRetrievalTest < Inferno::Test
    id :smart_access_brands_retrieve_bundle_test
    title 'Server returns publicly accessible SMART Access Brands Bundle'
    description %(
        Verify that the publisher's User Access Brands Bundle can be publicly
        accessed at the supplied URL location.
      )

    makes_request :bundle_request

    run do
      get(tags: ['smart_access_brands_bundle'])
      assert_response_status(200)
      assert(response.headers.include?('Access-Control-Allow-Origin'), %(
        All GET requests must support Cross-Origin Resource Sharing (CORS) for all GET requests to the artifacts
        described in this guide.))
      unless response.headers.include?('Etag')
        add_message('warning', 'Brand Bundle HTTP responses should include an Etag header')
      end
    end
  end
end
