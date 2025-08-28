Feature: Create Remuneration Fees

  Scenario:
    * configure headers = { "X-API-Key": #(eventsKey) }
    Given  url baseUrl+'/remuneration_fees'
    And request createRenumerationFeesBpsPayload
    And set createRenumerationFeesBpsPayload.annex_id = annexId
    And set createRenumerationFeesBpsPayload.id = idRemuneration
    When method POST
    Then status 201
    And match $.annex_id == annexId

    Given  url baseUrl+'/remuneration_fees'
    And request createRenumerationFeesBpsPayload
    And set createRenumerationFeesBpsPayload.annex_id = annexId2
    And set createRenumerationFeesBpsPayload.id = idRemuneration2
    When method POST
    Then status 201
    And match $.annex_id == annexId2
    * def calculatedBpsValue = $.calculated_value

    Given  url baseUrl+'/remuneration_fees'
    And request createRenumerationFeesBpsPayload
    And set createRenumerationFeesBpsPayload.annex_id = annexIdAmendment
    And set createRenumerationFeesBpsPayload.id = idRemunerationAmendment
    When method POST
    Then status 201
    And match $.annex_id == annexIdAmendment
    * def calculatedBpsValue = $.calculated_value
