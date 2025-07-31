module SMARTAppLaunch
  class StandaloneClinicianAccessAttestationTest < Inferno::Test
    title 'Supports the clinician access for standalone apps capabilities'
    id :standalone_clinician_access
    description %(
      The server supports the clinician access for standalone apps capabilities:
      1. `launch-standalone`
      2. At least one of `client-public` or `client-confidential-symmetric`
      3. `permission-user`
      4. `permission-patient`
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@350'

    input :standalone_clinician_access_correct,
          title: 'Supports the clinician access for standalone apps capabilities',
          description: %(
            I attest that the server supports the clinician access for standalone apps capabilities:
          ),
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Yes',
                value: 'true'
              },
              {
                label: 'No',
                value: 'false'
              }
            ]
          }
    input :standalone_clinician_access_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert standalone_clinician_access_correct == 'true',
             'Server does not support the clinician access for standalone apps capabilities.'
      pass standalone_clinician_access_note if standalone_clinician_access_note.present?
    end
  end
end
