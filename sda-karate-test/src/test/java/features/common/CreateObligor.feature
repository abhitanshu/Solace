Feature: Create Obligor
  Scenario:
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/obligors'
    And request createObligorPayload
    And set createObligorPayload.number = obligorNum
    When method POST
    Then status 201
    And match $.name == createObligorPayload.name
    And match $.number == obligorNum
