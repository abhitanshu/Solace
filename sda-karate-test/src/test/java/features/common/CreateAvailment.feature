Feature: Create Availment

  Scenario:
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/availments'
    And request availmentData.payload
    And set availmentData.payload.contract_code = contractCode
    When method POST
    Then status 201
    And match $.contract.code == contractCode
    And match $.contract.obligor_number == obligorNum
