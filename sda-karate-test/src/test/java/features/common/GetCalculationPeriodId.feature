Feature: Get Calculation Period Id

  Scenario:
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/calculation_periods?ucp_id='+ucpId
    When method GET
    Then status 200
    And match $.items[0].ucp_id == ucpId
    * def calculationPeriodId = $.items[0].id
