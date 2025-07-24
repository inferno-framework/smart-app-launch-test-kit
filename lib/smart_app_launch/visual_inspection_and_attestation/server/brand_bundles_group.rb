require_relative 'brand_bundles_group/brand_bundle_population_test'
require_relative 'brand_bundles_group/server_brand_bundles_test'
require_relative 'brand_bundles_group/fhir_server_brand_bundles_test'

module SMARTAppLaunch
  class BrandBundlesAttestationGroup < Inferno::TestGroup
    id :brand_bundles_group
    title 'Brand Bundles'

    run_as_group
    test from: :brand_bundle_population
    test from: :server_brand_bundles
    test from: :fhir_server_brand_bundles
  end
end
