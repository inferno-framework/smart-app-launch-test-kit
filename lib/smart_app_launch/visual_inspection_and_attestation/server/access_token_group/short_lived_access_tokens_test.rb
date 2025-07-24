module SMARTAppLaunch
  class ShortLivedAccessTokensAttestationTest < Inferno::Test
    title 'Issues access tokens that are short-lived'
    id :short_lived_access_tokens
    description %(
      The server issues access tokens that are short-lived.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@261'
  end
end
