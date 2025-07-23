module SMARTAppLaunch
  class PKCESupportAttestation < Inferno::Test
    title ''
    id :pkce_support
    description %(
      - Supports the `S256` `code_challenge_method`
      - Does not support the `plain` method
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@14',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@15'
  end
end