module SMARTAppLaunch
  class OpenIDFHIRUserClaimTestSTU22 < OpenIDFHIRUserClaimTest
    id :smart_openid_fhir_user_claim_stu2_2

    makes_request :fhir_user

    fhir_client do
      url :url
      oauth_credentials :smart_credentials
      headers 'Origin' => Inferno::Application['inferno_host']
    end

    def perform_fhir_read(fhir_user_resource_type, fhir_user_id)
      fhir_read(fhir_user_resource_type, fhir_user_id, name: :fhir_user)
    end
  end
end
