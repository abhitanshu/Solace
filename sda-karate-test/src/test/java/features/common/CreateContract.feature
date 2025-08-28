Feature: Create Contract

  Scenario:
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/contracts'
    And request createContractPayload
    And set createContractPayload.code = contractCode
    And set createContractPayload.obligor_number = obligorNum
    And set createContractPayload.atlas_facility_id = null
    When method POST
    Then status 201
    And match $.code == contractCode
    And match $.obligor_number == obligorNum
