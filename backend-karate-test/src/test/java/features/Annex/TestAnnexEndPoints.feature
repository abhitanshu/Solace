@Annex @Platform
Feature: Test Annex Endpoints
Background:
  * call read('classpath:features/common/Background.feature')

  Scenario: Verify Create and Get Endpoints for Annex
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
    * def ucpPackageId = $.ucpPackageId

    # Get UCP Package
    Given  url baseUrl+'/ucp_packages/'+ucpPackageId
    When method GET
    Then status 200

    # Get the Annex Id
    # Update the test after Annex amendment, We shall have more than 1 annex under a UCP agreement then.
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