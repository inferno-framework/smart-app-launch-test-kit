module SMARTAppLaunch
  class BrandBundlePopulationAttestation < Inferno::Test
    title ''
    id :brand_bundle_population
    description %(
      - Populates `Bundle.timestamp` to advertise the timestamp of the last change to the contents
      - Populates `Bundle.entry.resource.meta.lastUpdated` with a more detailed timestamp if the system tracks
        updates per Resource
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@418',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@419'
  end
end