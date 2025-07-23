module SMARTAppLaunch
  class AttestationTest219 < Inferno::Test
    title 'Attestation Test 219'
    id :attestation_test_219
    description %(
When URI representations are required, the SMART scopes SHALL be prefixed with `http://smarthealthit.org/fhir/scopes/`, so that a `patient/*.r` scope would be `http://smarthealthit.org/fhir/scopes/patient/*.r`
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@219'

    
  end
end