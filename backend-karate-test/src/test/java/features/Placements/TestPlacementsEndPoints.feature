@Placements @Platform
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
    # Create Second Placement
    Given  url baseUrl+'/exposures/'+exposureId+'/placements'
    * set createPlacementPayload.guarantorId = guarantorId
    * set createPlacementPayload.guarantorId = guarantorId
    And request createPlacementPayload
    When method POST
    Then status 201
    * def placementId = $.id

    # Get Placement List
    Given  url baseUrl+'/exposures/'+exposureId+'/placements'
    When method GET
    Then status 200
    And match $.totalElements == 2
    And match $.elements[0].exposureId == exposureId
    And match $.elements[1].exposureId == exposureId
    And match $.elements[0].guarantorId == guarantorId
    And match $.elements[1].guarantorId == guarantorId

   # Get Placement Details
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    When method GET
    Then status 200
    And match $.exposureId == exposureId
    And match $.guarantor.id == guarantorId

  Scenario: Verify the error when Placement is more than Gross amount including tolerence
    # Create First Placement
    * call read('classpath:features/common/CreateAgreement.feature')
    * call read('classpath:features/Guarantors/TestGuarantorEndPoints.feature')
    # Set Participation Structure and Retention Percentage for Agreement
    * call read('classpath:features/common/CreateParticipationStrucAndretentionPerc.feature')
    Given  url baseUrl+'/exposures/'+exposureId+'/placements'
    * set createPlacementPayload.guarantorId = guarantorId
    * set createPlacementPayload.participationAmount = 5500
    And request createPlacementPayload
    When method POST
    Then status 201
    # Create Second Placement with amount > agreement.lcAmount + agreement.lcAmount*tolerence - agreement.lcAmount*retentionPercentage
    Given  url baseUrl+'/exposures/'+exposureId+'/placements'
    * set createPlacementPayload.guarantorId = guarantorId
    * set createPlacementPayload.participationAmount = 5000
    And request createPlacementPayload
    When method POST
    Then status 400
    And match $.messageDescription ==  '#regex ^Total sum of placements for exposure with id: .+ should not exceed 10000.00.'

  Scenario: Verify 4 eye check in Placements
    # Scenarios verified here -
#    1. Delete is possible in Concept
#    2. startDate can be updated only if status is CONCEPT
#    3. ucpPackageId is NULL when status is CONCEPT, and have a value in other status
#    4. Delete is not possible in ACTIVE
#    5. PATCH request is used to change the status from CONCEPT-->ACTIVE and ACTIVE_CONCEPT-->MATURED
#    6. Start date can't be updated in status ACTIVE
#    7. any other fields than start Date can be used to make status ACTIVE --> ACTIVE_CONCEPT
#    8. Start date can't be updated in status ACTIVE_CONCEPT
#    9. Delete is not possible in ACTIVE_CONCEPT
#    10. Changing status from ACTIVE --> CONCEPT is not allowed
#    11. Placement status cannot be updated from MATURED --> ACTIVE_CONCEPT
#    12. Delete is not possible in MATURED

  # Create First Placement
    * call read('classpath:features/common/CreateAgreement.feature')
    * call read('classpath:features/Guarantors/TestGuarantorEndPoints.feature')
    # Set Participation Structure and Retention Percentage for Agreement
    * call read('classpath:features/common/CreateParticipationStrucAndretentionPerc.feature')
    Given  url baseUrl+'/exposures/'+exposureId+'/placements'
    And header Authorization = 'maker_abhi@example.com'
    * set createPlacementPayload.guarantorId = guarantorId
    And request createPlacementPayload
    When method POST
    Then status 201
    And match $.ucpPackageId == null
    And match $.status == "CONCEPT"
    * def placementId = $.id
  # Delete is possible in Concept
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    When method DELETE
    Then status 200
  # Re-Create First Placement
    * call read('classpath:features/common/CreateAgreement.feature')
    * call read('classpath:features/Guarantors/TestGuarantorEndPoints.feature')
    # Set Participation Structure and Retention Percentage for Agreement
    * call read('classpath:features/common/CreateParticipationStrucAndretentionPerc.feature')
    Given  url baseUrl+'/exposures/'+exposureId+'/placements'
    And header Authorization = 'maker_abhi@example.com'
    * set createPlacementPayload.guarantorId = guarantorId
    And request createPlacementPayload
    When method POST
    Then status 201
    And match $.ucpPackageId == null
    And match $.status == "CONCEPT"
    * def placementId = $.id
  # Get Placement Details
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    When method GET
    Then status 200
    And match $.ucpPackageId == null
    And match $.status == "CONCEPT"
    And match $.exposureId == exposureId
    And match $.guarantor.id == guarantorId
  #Update the Placement - startDate can be updated only if status is CONCEPT
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    And header Authorization = 'maker_abhi@example.com'
    #guarantorId id not needed for Update Placement
    * set updatePlacementPayload.name = "Updated_Placement_1"
    * set updatePlacementPayload.participationAmount = 4400
    * set updatePlacementPayload.participationPercentage = 40.00
    * set updatePlacementPayload.feePercentage = 55.00
    * set updatePlacementPayload.startDate = "2025-07-10"
    * set updatePlacementPayload.endDate = "2027-07-10"
    And request updatePlacementPayload
    When method PUT
    Then status 200
  #Make the status as active
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    And header Authorization = 'checker_abhi@example.com'
    And request {"status": "ACTIVE"}
    When method PATCH
    Then status 200
    * def ucpPackageId = $.ucpPackageId
  #Get Placement Details
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    When method GET
    Then status 200
    And match $.ucpPackageId == ucpPackageId
    And match $.status == "ACTIVE"
    And match $.exposureId == exposureId
    And match $.guarantor.id == guarantorId
  # Delete is not possible in ACTIVE
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    When method DELETE
    Then status 400
    And match $.messageDescription == "Placement can only be deleted when it has Concept as status and doesn't have linked UCP Package"
  #Update the Placement - Start date can't be updated in status ACTIVE
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    And header Authorization = 'maker_abhi@example.com'
    * set updatePlacementPayload.startDate = "2025-08-10"
    And request updatePlacementPayload
    When method PUT
    Then status 400
    And match $.messageDescription == "Placement start date cannot be modified for a placement with status: ACTIVE"
  #Update any other fields than start Date to make status Active --> Active_Concept
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    And header Authorization = 'maker_abhi@example.com'
  # make sure startDate has the previously updated value
    * set updatePlacementPayload.startDate = "2025-07-10"
    * set updatePlacementPayload.endDate = "2027-10-10"
    * set updatePlacementPayload.feePercentage = 65.55
    And request updatePlacementPayload
    When method PUT
    Then status 200
  #Get Placement Details
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    When method GET
    Then status 200
    And match $.ucpPackageId == ucpPackageId
    And match $.status == "ACTIVE_CONCEPT"
    And match $.exposureId == exposureId
    And match $.guarantor.id == guarantorId
  #Update the Placement - Start date can't be updated in status ACTIVE_CONCEPT
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    And header Authorization = 'maker_abhi@example.com'
    * set updatePlacementPayload.startDate = "2025-08-10"
    And request updatePlacementPayload
    When method PUT
    Then status 400
    And match $.messageDescription == "Placement start date cannot be modified for a placement with status: ACTIVE_CONCEPT"
  # Delete is not possible in ACTIVE_CONCEPT
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    When method DELETE
    Then status 400
    And match $.messageDescription == "Placement can only be deleted when it has Concept as status and doesn't have linked UCP Package"
  #Make the status as active
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    And header Authorization = 'checker_abhi@example.com'
    And request {"status": "ACTIVE"}
    When method PATCH
    Then status 200
  #Make the status as Concept - which is not allowed
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    And header Authorization = 'checker_abhi@example.com'
    And request {"status": "CONCEPT"}
    When method PATCH
    Then status 400
    And match $.messageDescription == "Placement status cannot be updated from ACTIVE to CONCEPT"
  #Make the status as matured
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    And header Authorization = 'checker_abhi@example.com'
    And request {"status": "MATURED"}
    When method PATCH
    Then status 200
  #Get Placement Details
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    When method GET
    Then status 200
    And match $.ucpPackageId == ucpPackageId
    And match $.status == "MATURED"
    And match $.exposureId == exposureId
    And match $.guarantor.id == guarantorId
  #Make the status as matured
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    And header Authorization = 'checker_abhi@example.com'
    And request {"status": "ACTIVE_CONCEPT"}
    When method PATCH
    Then status 400
    And match $.messageDescription == "Placement status cannot be updated from MATURED to ACTIVE_CONCEPT"
  # Delete is not possible in MATURED
    Given  url baseUrl+'/exposures/'+exposureId+'/placements/'+placementId
    When method DELETE
    Then status 400
    And match $.messageDescription == "Placement can only be deleted when it has Concept as status and doesn't have linked UCP Package"


  Scenario Outline: Verify fields validations for Placements - <field>
    # Create First Placement
    * call read('classpath:features/common/CreateAgreement.feature')
    * call read('classpath:features/Guarantors/TestGuarantorEndPoints.feature')
    # Set Participation Structure and Retention Percentage for Agreement
    * call read('classpath:features/common/CreateParticipationStrucAndretentionPerc.feature')
    Given  url baseUrl+'/exposures/'+exposureId+'/placements'
    * set createPlacementPayload.guarantorId = guarantorId
    * set createPlacementPayload.participationAmount = 5500
    * set createPlacementPayload.<field> = <Value>
    And request createPlacementPayload
    When method POST
    Then status 400
    And match $.messageDescription == <errorMessage>
    Examples:
      | field                   | Value                                       | errorMessage                                               |
      | endDate                 | testUtil.getDateAfterDaysfromCurrentDate(0) | '#regex ^End date: .+ should be in the future'             |
      | feePercentage           | -10.00                                      | 'Validation error'                                         |
      | feePercentage           | 101                                         | 'Validation error'                                         |
      #retentionPercentage is 10 so participationPercentage can't be more than 90
      | participationPercentage | 90.01                                       | 'Participation Percentage: 90.01 should not exceed 90.00.' |
      | participationPercentage | -10.00                                      | 'Validation error'                                         |
  # Below test to be enabled after Mine fixes the calculation in backend
#      | participationAmount     | 4951                                        | 'Validation error'                                         |