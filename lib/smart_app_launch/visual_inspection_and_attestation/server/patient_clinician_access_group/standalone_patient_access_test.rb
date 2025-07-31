module SMARTAppLaunch
  class StandalonePatientAccessAttestationTest < Inferno::Test
    title 'Supports the patient access for standalone apps capabilities'
    id :standalone_patient_access
    description %(
      The server supports the patient access for standalone apps capabilities:
      1. `launch-standalone`
      2. At least one of `client-public` or `client-confidential-symmetric`
      3. `context-standalone-patient`
      4. `permission-patient`
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@348'

    input :standalone_patient_access_correct,
          title: 'Supports the patient access for standalone apps capabilities',
          description: %(
            I attest that the server supports the patient access for standalone apps capabilities:
            1. `launch-standalone`
            2. At least one of `client-public` or `client-confidential-symmetric`
            3. `context-standalone-patient`
            4. `permission-patient`
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
    input :standalone_patient_access_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert standalone_patient_access_correct == 'true',
             'Server does not support the patient access for standalone apps capabilities.'
      pass standalone_patient_access_note if standalone_patient_access_note.present?
    end
  end
end
