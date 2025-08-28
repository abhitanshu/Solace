@UCPPackage @Platform
Feature: Test Placements Endpoints
Background:
  * call read('classpath:features/common/Background.feature')

  Scenario: Verify Create and Get Endpoints for Placements
    # Create First Placement
    * call read('classpath:features/common/CreateAgreement.feature')
    * call read('classpath:features/Guarantors/TestGuarantorEndPoints.feature')
    # Set Participation Structure and Retention Percentage for Agreement
    * call read('classpath:features/common/CreateParticipationStrucAndretentionPerc.feature')
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
    * def ucpPackageId1 = $.ucpPackageId


    # Create Second Placement
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
    * def ucpPackageId2 = $.ucpPackageId

    # Get UCP Package1
    Given  url baseUrl+'/ucp_packages/'+ucpPackageId1
    When method GET
    Then status 200

    # Get UCP Package2
    Given  url baseUrl+'/ucp_packages/'+ucpPackageId2
    When method GET
    Then status 200