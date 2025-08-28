Feature: Create Annex

  Scenario:
    * configure headers = { "X-API-Key": #(eventsKey) }
    Given  url baseUrl+'/annexes'
    And request annexData.payload
    And header Authorization = notification.authorization_header
    And set annexData.payload.annex_id = annexId
    And set annexData.payload.ucp_id = ucpId
    When method POST
    Then status 201
    And match $.annex_id == annexId
    And match $.ucp_id == ucpId
