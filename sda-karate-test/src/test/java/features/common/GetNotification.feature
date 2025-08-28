Feature: Get Notification

  Scenario:
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/notifications/'
    And header Authorization = notification.authorization_header
    When method GET
    Then status 200
    And match $.items[0].ucp_id == ucpId
    And match $.items[0].type == notification.expected_type
    And match $.items[0].calculation_period_id == notification.expected_calculation_period_id
