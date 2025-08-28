@Platform @E2E
Feature: End to End Test for Solace Platform
Background:
  * call read('classpath:features/common/Background.feature')

  Scenario: End to End Test for Solace Platform

    #Create Obligor
    Given  url baseUrlLimitMgmt+'/obligors'
    And request createObligorPayload
    And set createObligorPayload.name = obligorName
    When method POST
    Then status 201
    And match $.name == obligorName
    * def obligorId = $.id

  # Create Exposure
    Given  url baseUrl+'/exposures'
    And request createAgreementPayload
    And set createAgreementPayload.obligorId = obligorId
    When method POST
    Then status 201
    * def exposureId = $.id

  # Create Guarantors
    Given  url baseUrl+'/guarantors'
    * set createGuarantorPayload.parentCompany.name = testUtil.getRandomString(10)
    And request createGuarantorPayload
    When method POST
    Then status 201
    * def guarantorId = $.id

  # Create placement settings
    Given  url baseUrl+'/exposures/'+exposureId
    And request {"participationStructure": "FIXED_AMOUNT","retentionPercentage": 10}
    When method PATCH
    Then status 200

  # Create Placements
    Given  url baseUrl+'/exposures/'+exposureId+'/placements'
    * set createPlacementPayload.guarantorId = guarantorId
    And request createPlacementPayload
    When method POST
    Then status 201
    * def placementId = $.id

  #Make the status as active
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    And header Authorization = 'checker_abhi@example.com'
    And request {"status": "ACTIVE"}
    When method PATCH
    Then status 200
    * def ucpPackageId = $.ucpPackageId

  # Get UCP Package
    Given  url baseUrl+'/ucp_packages/'+ucpPackageId
    When method GET
    Then status 200

  # Get the Annex Id
    Given  url baseUrl+'/annexes?ucpPackageId='+ucpPackageId
    When method GET
    Then status 200
    * def annexId = $.elements[0].id

  # List the Annex
    Given  url baseUrl+'/annexes/'+annexId
    When method GET
    Then status 200

  # Get Annex PDF
    Given  url baseUrl+'/annexes/'+annexId+'/pdf'
    When method GET
    Then status 200