module SMARTAppLaunch
  class ServerAttestationGroupSTU22 < Inferno::TestGroup
    id :smart_server_visual_inspection_and_attestation_stu2_2

    title 'Visual Inspection and Attestation'

    description <<~DESCRIPTION
      Perform visual inspections or attestations to ensure that the Server is conformant to the SMART App Launch IG requirements.
    DESCRIPTION

    run_as_group
  end
end