Feature: Check calculation period with ContractCode
  Scenario:
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/notifications/check-calculation-period/'+contractCode
    When method POST
    Then status 201
    And match $[0].ucp_id == ucpId
    And match $[0].type == "needs_review"
    And match $[0].contract_code == contractCode
