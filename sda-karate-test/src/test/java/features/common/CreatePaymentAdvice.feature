Feature: Create Payment Advice

  Scenario:
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/payment_advice'
    And request sendCalculationPeriodIdPayload
    And set sendCalculationPeriodIdPayload.ucp_id = ucpId
    When method POST
    Then status 201
    * def paymentAdviceId = $.id
    And match $.status == "Created"
