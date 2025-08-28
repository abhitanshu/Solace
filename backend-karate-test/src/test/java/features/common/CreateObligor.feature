Feature: Create Obligor
  Scenario:
    Given  url baseUrlLimitMgmt+'/obligors'
    And request createObligorPayload
    And set createObligorPayload.name = obligorName
    When method POST
    Then status 201
    And match $.name == obligorName
    * def obligorId = $.id
